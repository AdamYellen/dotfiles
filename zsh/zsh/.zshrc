# setup paths
typeset -U path      # Make sure path entries are unique
path+=~/.bin
# path=(~/bin ~/progs/bin $path)

# set zsh options
setopt AUTO_CD       # skip 'cd path' and just type 'path'
setopt HIST_VERIFY

# load our functions
source "$ZDOTDIR/zsh-functions"

# load our files
zsh_add_file "zsh-aliases"

# setup completions
autoload -U compinit
compinit
