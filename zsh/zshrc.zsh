
# Aliases
alias f='find . -type d -name .svn -prune -o -type f -and -not -name "*.pb.*" -and -not -name "tags" -and -not -name "*.js.map" -print0 | xargs -0 grep -I --color -H -n '

alias plistbuddy="/usr/libexec/PlistBuddy"
alias icloud="cd $HOME/Library/Mobile\ Documents/com\~apple\~CloudDocs"
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

alias a="ansible"
alias ap="ansible-playbook"

if command -v eza >/dev/null
then
   alias ls="eza --icons --group-directories-first"
   alias ll="eza --icons --group-directories-first -l"
else
   alias ll="ls -l"
fi

if [[ -d $HOME/.bin ]]
then
   export PATH=$PATH:$HOME/.bin
fi
