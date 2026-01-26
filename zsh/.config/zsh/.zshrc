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
path=(~/.bin $path)

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

# Configure Homebrew
export HOMEBREW_AUTO_UPDATE_SECS=604800

##
# Set environment for using 1Password SSH Agent and CLI over SSH such
# that SSH Agent and 1Password CLI can be forwarded over SSH sessions
# consistently on macOS and Linux.
#
# See: https://github.com/mmercurio/dotfiles
#
# Requirements:
# - ~/.1password/agent.sock is symlinked to 1Password's SSH Agent socket.
#   (This is the default for Linux, but not not macOS.)
# - ~/bin/op is symlinked to 1Password CLI
# - ~/.ssh/config includes option to send LC_DESKTOP_HOST ("SendEnv LC_DESKTOP_HOST")
#
# This file is expected to be sourced by the login shell.
#
# When logged in locally on the desktop:
# - SSH_AUTH_SOCK is set and pointing to 1Password's ssh-agent socket.
# - LC_DESKTOP_HOST is set to the current hostname where 1Password is running.
#
# When logged in remotely over SSH:
# - `op` is aliased to run over SSH to the desktop where 1Password is running.
#
# When not logged in remotely over SSH, set SSH_AUTH_SOCK to use 1Password as SSH Agent.
# When logged in remotely over SSH, use `op_over_ssh` wrapper for `op`.
if [[ -z "$SSH_CONNECTION" ]]
then
    export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
    if command -v /usr/local/bin/op > /dev/null
    then
        # if running locally and 1Password CLI is available set LC_DESKTOP_HOST
        export LC_DESKTOP_HOST=$(hostname)
    fi
fi

# Load fancy prompt
source "$HOME/.config/zsh/agkozak-zsh-prompt/agkozak-zsh-prompt.plugin.zsh"
AGKOZAK_CUSTOM_SYMBOLS=( '⇣⇡' '⇣' '⇡' '+' 'x' '!' '>' '?' 'S')
AGKOZAK_PROMPT_CHAR=( ❯ ❯ ❮ )
AGKOZAK_COLORS_PROMPT_CHAR='magenta'
