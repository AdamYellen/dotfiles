# Order: .zshenv → [.zprofile if login] → [.zshrc if interactive] → [.zlogin if login] → [.zlogout sometimes]
# NB: On macOS /etc/zprofile runs 'path_helper -s' which reorders the path. To get paths set correctly we need to set it here instead of '.zshenv'.

# Allow Homebrew to setup environment (path, fpath, manpath, infopath)
if [[ -x /opt/homebrew/bin/brew ]]
then
   eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Pull in our private environment
if [[ -f ~/.sync/.zshenv ]]
then
   . ~/.sync/.zshenv
fi
