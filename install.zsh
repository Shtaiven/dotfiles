#!/usr/bin/env zsh
# Installs dotfiles to home directory.
#
# Authors:
#   Steven Eisinger
#

# vars
INSTALL_DIR="${ZDOTDIR:-$HOME}"
SOURCE_DIR="$0:A:h"
ECHO="echo"
LN_OPTS="-sf"

setopt EXTENDED_GLOB

# install prezto if it doesn't exist
if [[ ! -d "$INSTALL_DIR/.zprezto" ]]; then
    $ECHO "Installing prezto to $INSTALL_DIR/.zprezto"
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$INSTALL_DIR/.zprezto"
fi

# install zsh dotfiles and prezto config
for rcfile in $SOURCE_DIR/runcoms/^README.md(.N); do
    $ECHO "Installing $rcfile to $INSTALL_DIR/.${rcfile:t}"
    ln $LN_OPTS "$rcfile" "$INSTALL_DIR/.${rcfile:t}"
done

# install powerlevel10k config
$ECHO "Installing $SOURCE_DIR/p10k.zsh to $INSTALL_DIR/.p10k.zsh"
ln $LN_OPTS "$SOURCE_DIR/p10k.zsh" "$INSTALL_DIR/.p10k.zsh"
