# KOReader Dictionary Mode Plugin

Fork of [ckilb/koreader-dictionarymode](https://github.com/ckilb/koreader-dictionarymode) with proper language support (the original implementation fails to apply processing provided by language support plugins).

This plugin will add a new option `Dictionary Mode` under `Main Menu > Settings > Taps and Gestures`.\
When enabled, dictionary lookups will be triggered simply by tapping a word.

Please mind that _dictionary mode_ will conflict with other tap actions like page turns or corner taps and disable them.\
For page turns, either use your device's hardware buttons (if any) or swiping.

The plugin activates the dictionary by simulating a hold event when the user taps on the screen.
This way, additional steps that might be required by a certain language, like finding proper word boundaries or deinflection, will be applied before the lookup itself.

~~A caveat of this method is that it might fail to open the dictionary if you do not have enabled `Dictionary on single word selection` under `Main Menu > Settings > Taps and Gestures`.~~ It seems this is not a problem actually.

## Install
Clone this repository (or download as zip via `<> Code -> Download ZIP` and extract the folder) and place it in the *plugins* folder inside your KOReader directory.
You can delete the *.git* folder if you want.
If everything works alright, you should be able to see a new `Dictionary Mode` checkbox in the `Main Menu > Settings > Taps and Gestures` menu and an entry in the plugin list in `Main Menu > Options > More Tools > Plugin Management`.

## Alternatives
You can improve the snappiness of the hold action by reducing the value of `Long-press interval` from the default of `500ms` to something like `200ms` (in `Main Menu > Settings > Taps and Gestures > Gesture Intervals > Long-press interval`).
