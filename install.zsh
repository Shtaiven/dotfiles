#!/usr/bin/env zsh
# Installs dotfiles to home directory.
#
# Authors:
#   Steven Eisinger <steven.a.eisinger@gmail.com>
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

# install config files
for cfile in $SOURCE_DIR/config/**/*(.)^README.md(.N); do
    $ECHO "Installing $cfile to $INSTALL_DIR/.config/.${cfile:t}"
    ln $LN_OPTS "$cfile" "$INSTALL_DIR/.config/.${cfile:t}"
done

# install starship for prompt customization
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y

