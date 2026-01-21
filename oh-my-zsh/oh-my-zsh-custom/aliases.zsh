# Find recursively
alias f='find . -type d -name .svn -prune -o -type f -and -not -name "*.pb.*" -and -not -name "tags" -and -not -name "*.js.map" -print0 | xargs -0 grep -I --color -H -n '

# PlistBuddy alias, because sometimes `defaults` just doesn’t cut it
alias plistbuddy="/usr/libexec/PlistBuddy"

# Short to iCloud Drive folder
alias icloud="cd $HOME/Library/Mobile\ Documents/com\~apple\~CloudDocs"

# Flush DNS cache on macOS
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
