#!/bin/bash

# Install/update oh-my-zsh
if ! [ -d "$HOME/.oh-my-zsh" ]
then
  # Don't run the new shell when install finishes (--unattended)
  # Don't replace existing zshrc file (--keep-zshrc)
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

  # Remove default .zshrc so we can link our own
  rm -f ~/.zshrc
fi
exit 0
