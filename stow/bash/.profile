# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

#
# cargo
#

if [ -x "$(command -v cargo)" ]; then
    . "$HOME/.cargo/env"
fi

# pyenv
if [ -x "$(command -v pyenv)" ]; then
    eval "$(pyenv init --path)"
fi

# vulkan for nvidia gpu
export VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/nvidia_icd.json"

# Use kvantum for Qt theme
# export QT_STYLE_OVERRIDE=kvantum

# Use gtk style for Qt theme
export QT_QPA_PLATFORMTHEME=qt5ct

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
