# Portable login environment — sourced by both .profile and .zprofile
# Must be POSIX sh compliant

# Deduplicated PATH helpers (POSIX sh)
path_prepend() { case ":$PATH:" in *:"$1":*) ;; *) PATH="$1:$PATH" ;; esac }
path_append() { case ":$PATH:" in *:"$1":*) ;; *) PATH="$PATH:$1" ;; esac }

# Common PATH
[ -d "$HOME/.pixi/bin" ] && path_prepend "$HOME/.pixi/bin"
[ -d "$HOME/.local/bin" ] && path_prepend "$HOME/.local/bin"
[ -d "$HOME/local/bin" ] && path_prepend "$HOME/local/bin"
[ -d "$HOME/bin" ] && path_prepend "$HOME/bin"
export PATH

# Pager
export PAGER='less'
export LESS='-g -i -M -R -S -w -z-4'
if command -v lesspipe >/dev/null 2>&1; then
	export LESSOPEN="| lesspipe %s"
elif command -v lesspipe.sh >/dev/null 2>&1; then
	export LESSOPEN="| lesspipe.sh %s"
fi

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
	path_prepend "$PYENV_ROOT/bin"
	command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init --path)"
fi

# cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Vulkan fix for nvidia gpu
export VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/nvidia_icd.json"

# envman
[ -s "$HOME/.config/envman/load.sh" ] && . "$HOME/.config/envman/load.sh"
