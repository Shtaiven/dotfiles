# Portable login environment — sourced by both .profile and .zprofile
# Must be POSIX sh compliant

# pyenv
if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init --path)"
fi

# cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Vulkan fix for nvidia gpu
export VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/nvidia_icd.json"

# Qt theme
export QT_QPA_PLATFORMTHEME=qt5ct

# envman
[ -s "$HOME/.config/envman/load.sh" ] && . "$HOME/.config/envman/load.sh"
