#!/usr/bin/env zsh

# current script dir
INSTALL_DIR="${ZDOTDIR:-$HOME}"
SOURCE_DIR="$0:A:h"

# install zsh dotfiles and prezto config
setopt EXTENDED_GLOB
for rcfile in $SOURCE_DIR/runcoms/^README.md(.N); do
    ln -sf "$rcfile" "$INSTALL_DIR/.${rcfile:t}"
done

# install powerlevel10k config
ln -sf $SOURCE_DIR/p10k.zsh $INSTALL_DIR/.p10k.zsh
