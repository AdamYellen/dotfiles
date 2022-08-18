#!/usr/bin/env osascript
on run
	tell application "Terminal"
		set defaultName to name of default settings
		set font size of settings set defaultName to 12
		set font name of settings set defaultName to "Meslo LG M DZ Regular for Powerline"
	end tell
end run0
