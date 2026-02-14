#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"

DIRS=(
  "bat"
  "bin"
  "ghostty"
  "git"
  "gnupg"
  "ssh"
  "vim"
  "zsh"
)

for dir in "${DIRS[@]}"; do
  stow -d "$DOTFILES_DIR" -t "$HOME" -S "$dir"
done
