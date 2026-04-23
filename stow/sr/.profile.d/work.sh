# Work-specific login environment
# shellcheck shell=bash

# JetBrains Toolbox
if [ -d "$HOME/.local/share/JetBrains/Toolbox/scripts" ]; then
	path_append "$HOME/.local/share/JetBrains/Toolbox/scripts"
fi

# Nix
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
