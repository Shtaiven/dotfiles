# Portable login environment — sourced by both .profile and .zprofile
# Must be POSIX sh compliant

# Common PATH
[ -d "$HOME/.pixi/bin" ] && PATH="$HOME/.pixi/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/local/bin" ] && PATH="$HOME/local/bin:$PATH"
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
export PATH

# Editor
if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
  export VISUAL=nvim
else
  export EDITOR=vi
  export VISUAL=vi
fi

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

# envman
[ -s "$HOME/.config/envman/load.sh" ] && . "$HOME/.config/envman/load.sh"
