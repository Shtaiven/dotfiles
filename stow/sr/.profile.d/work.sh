# Work-specific login environment

# JetBrains Toolbox
if [ -d "$HOME/.local/share/JetBrains/Toolbox/scripts" ]; then
	export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"
fi

# Nix
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
