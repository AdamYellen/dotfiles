#!/bin/bash

# link the plist
# rm -f ~/Library/Preferences/com.apple.Terminal.plist
cp -f terminal.plist ~/Library/Preferences/com.apple.Terminal.plist

# Fix terminal fonts
# NOTE: the sync'd terminal profile references fonts by ID which can be different on each machine
./setup-terminal-font.scpt

# Close terminal windows on successful exit code
# /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.Terminal.plist -c "Set 'Window Settings':Basic:shellExitAction 1"
