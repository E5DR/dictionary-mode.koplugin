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
                ratio_x = 0, ratio_y = 0, ratio_w = 1, ratio_h = 1,
            },
            overrides = {
                "readerhighlight_tap",
                "tap_top_left_corner",
                "tap_top_right_corner",
                "tap_left_bottom_corner",
                "tap_right_bottom_corner",
                "readerfooter_tap",
                "readerconfigmenu_ext_tap",
                "readerconfigmenu_tap",
                "readermenu_ext_tap",
                "readermenu_tap",
                "tap_forward",
                "tap_backward",
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
    logger.dbg("DictionaryMode onTap handler - emulating hold")

    self.ui.highlight:onHold(nil, ges)
    self.ui.highlight:onHoldRelease()
    -- self.ui.highlight:clear()
    -- self.ui.document:clearSelection()

    return true
end



return DictionaryMode
