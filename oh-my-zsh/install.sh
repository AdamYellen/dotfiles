#!/bin/bash

# Install/update oh-my-zsh
if ! [ -d "$HOME/.oh-my-zsh" ]
then
  # Don't run the new shell when install finishes (--unattended)
  # Don't replace our zshrc file which was already installed by script/setup (--keep-zshrc)
  # Don't switch our shell to zsh (--skip-chsh)
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc --skip-chsh
fi
exit 0
