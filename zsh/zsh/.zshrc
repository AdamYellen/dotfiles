# Order: .zshenv → [.zprofile if login] → [.zshrc if interactive] → [.zlogin if login] → [.zlogout sometimes]

# Load our functions
source "$ZDOTDIR/zsh-functions"

# Make sure necessary directories exist
if [[ ! -d "$HOME/.cache" ]]
then
   mkdir "$HOME/.cache"
fi

# Paths
typeset -U path                  # Make sure path entries are unique
path+=~/.bin
# path=(~/bin ~/progs/bin $path)

# Options
setopt AUTO_CD                   # If only directory path is entered, cd there
setopt NO_CASE_GLOB              # Case insensitive globbing
setopt HIST_IGNORE_ALL_DUPS      # If a new command is a duplicate, remove the older one
setopt APPEND_HISTORY            # Append history on exit instead of overwriting
setopt HIST_VERIFY               # When using history expansion, give the user an opportuniy to edit before executing

# Aliases
alias f='find . -type d -name .svn -prune -o -type f -and -not -name "*.pb.*" -and -not -name "tags" -and -not -name "*.js.map" -print0 | xargs -0 grep -I --color -H -n '
alias plistbuddy="/usr/libexec/PlistBuddy"
alias icloud="cd $HOME/Library/Mobile\ Documents/com\~apple\~CloudDocs"
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
alias a="ansible"
alias ap="ansible-playbook"
if command -v eza >/dev/null
then
   alias ls="eza --icons --group-directories-first -A"
   alias l="eza --icons --group-directories-first -lA"
else
   alias ls="ls --color -AF"
   alias l="ls --color -lAF"
fi
alias grep="grep --color=auto"
alias diff="diff --color=auto"

# Completions
autoload -U compinit
compinit

# Other utils/exports
export LESSHISTFILE="$HOME/.cache/.lesshst"
export PYTHON_HISTORY="$HOME/.cache/.python_history"

# Setup 1Password SSH agent
if [[ -d "/Applications/1Password.app" ]]
then
   # Only set if it hasn't already been set, typically this would be the case if connecting remotely via SSH
   if [[ -z "$SSH_AUTH_SOCK" ]]
   then
      export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
   fi
fi
