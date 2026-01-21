# Order: .zshenv → [.zprofile if login] → [.zshrc if interactive] → [.zlogin if login] → [.zlogout sometimes]

# Set the directory for zsh to use for all subsequent files
# Some functions depend on this variable being set
ZDOTDIR="$HOME/.config/zsh"
