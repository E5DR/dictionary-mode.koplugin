local Dispatcher = require("dispatcher")  -- luacheck:ignore
local dbg = require("dbg")
local Event = require("ui/event")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")
local logger = require("logger")

local DictionaryMode = WidgetContainer:extend{
    name = "dictionarymode",
    is_doc_only = false,
}

function DictionaryMode:onDispatcherRegisterActions()
    Dispatcher:registerAction("dictionarymode_action", {category="none", event="DictionaryMode", title=_("Dictionary Mode"), general=true,})
end

function DictionaryMode:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)

    self:registerTap()
end

function DictionaryMode:addToMainMenu(menu_items)
    menu_items.dictionarymode = {
        text = _("Dictionary Mode"),
        sorting_hint = "taps_and_gestures",
        checked_func = function()
            return G_reader_settings:isTrue("enable_dictionary_mode")
        end,
        callback = function()
            local enabled = G_reader_settings:isTrue("enable_dictionary_mode")
            G_reader_settings:saveSetting("enable_dictionary_mode", not enabled)
        end,
    }
end

function DictionaryMode:onDictionaryMode()
    local enabled = G_reader_settings:isTrue("enable_dictionary_mode")
    local msg = "-"
    if enabled then
        msg = "Dictionary mode enabled"
    else
        msg = "Dictionary mode disabled"
    end

    local popup = InfoMessage:new{
        text = _(msg),
    }
    UIManager:show(popup)
end

function DictionaryMode:registerTap()
    self.ui:registerTouchZones({
        {
            id = "dictionarymode_tap",
            ges = "tap",
            screen_zone = {
                -- Keep a slight margin to allow tapping on the corners /
                -- status bar (note: not sure if you can actually get the
                -- bottom corners or if they are in conflict with the status
                -- bar)
                -- Trying to keep the values conservative and small in case
                -- someone has a large screen
                ratio_x = 0.01, ratio_y = 0.015, ratio_w = 0.98, ratio_h = 0.97,
            },
            overrides = {
                "readerhighlight_tap",
                -- "tap_top_left_corner",
                -- "tap_top_right_corner",
                -- "tap_left_bottom_corner",
                -- "tap_right_bottom_corner",
                -- "readerfooter_tap",
                "readerconfigmenu_ext_tap",
                "readerconfigmenu_tap",
                "readermenu_ext_tap",
                "readermenu_tap",
                -- "tap_forward",
                -- "tap_backward",
            },
            handler = function(ges) return self:onTap(nil, ges) end
        },
    })
end

function DictionaryMode:onTap(_, ges)
    local disabled = G_reader_settings:nilOrFalse("enable_dictionary_mode")
    if disabled then
        return false
    end

    -- Do not activate when no text is detected. This should allow triggering
    -- the original action, like a corner tap or a page flip.
    -- (Note in case tap_forward / tap_backward override is active: In this
    -- case tapping / holding below or above a text will still select the text
    -- even on free space. Therefore in that case tap-through will mostly
    -- happen when tapping in the left / right margins or the free space next
    -- to a paragraph.)
    local pos = self.view:screenToPageTransform(ges.pos)
    local text = self.ui.document:getTextFromPositions(pos, pos)
    if (not text) or (string.find(text.text, "\n") or string.find(text.text, " ")) then
        logger.dbg("DictionaryMode: Tap detected, but no text - nothing to do")
        -- Clear highlights since in some cases a highlight will be created but
        -- not cleared for some reason
        self.ui.highlight:clear()
        return false
    end

    logger.dbg("DictionaryMode: Emulating hold")
    local status = self.ui.highlight:onHold(nil, ges)
    status = self.ui.highlight:onHoldRelease() and status

    return status
end



return DictionaryMode
