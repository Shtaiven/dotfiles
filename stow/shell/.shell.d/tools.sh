# Portable tool inits — sourced by both bash and zsh

# Detect current shell once
if [ -n "$ZSH_VERSION" ]; then _shell=zsh; elif [ -n "$BASH_VERSION" ]; then _shell=bash; fi

# fd / fzf
if command -v fd >/dev/null 2>&1; then
	export FZF_CTRL_T_COMMAND="fd --hidden --follow --exclude \".git\" . $HOME"
	export FZF_ALT_C_COMMAND="fd -t d --hidden --follow --exclude \".git\" . $HOME"

	_fzf_compgen_path() {
		fd --type f --hidden --follow --exclude .git . "$1"
	}
	_fzf_compgen_dir() {
		fd --type d . "$1"
	}
fi

# fzf shell integration (key bindings + completion fallback)
# Must run before carapace so carapace's complete -D takes precedence when present
if command -v fzf >/dev/null 2>&1; then
	export FZF_DEFAULT_OPTS="--color=16"
	export FZF_ALT_C_OPTS="--preview 'ls -la {}'"

	# bat preview for CTRL+T file browsing
	if command -v bat >/dev/null 2>&1; then
		export FZF_CTRL_T_OPTS="--preview 'bat --color=always --plain {}'"
	elif command -v batcat >/dev/null 2>&1; then
		export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --plain {}'"
	fi

	if [ -n "$ZSH_VERSION" ]; then
		eval "$(fzf --zsh 2>/dev/null)"
	elif [ -n "$BASH_VERSION" ]; then
		eval "$(fzf --bash 2>/dev/null)"
	fi
fi

# rgf — interactive ripgrep + fzf with bat preview
if command -v rg >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
	rgf() {
		local _preview
		if command -v bat >/dev/null 2>&1; then
			_preview='bat --color=always --plain --highlight-line {2} {1}'
		elif command -v batcat >/dev/null 2>&1; then
			_preview='batcat --color=always --plain --highlight-line {2} {1}'
		else
			_preview='sed -n {2}p {1}'
		fi
		rg --color=always --line-number --no-heading "${@:-}" |
			fzf --ansi \
				--delimiter=: \
				--preview "$_preview" \
				--preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
	}
fi

# starship
command -v starship >/dev/null 2>&1 && eval "$(starship init $_shell)"

# zoxide
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init $_shell)"

# carapace (cached)
if command -v carapace >/dev/null 2>&1; then
	_carapace_cache="${XDG_CACHE_HOME:-$HOME/.cache}/carapace_init.$_shell"
	if [ ! -f "$_carapace_cache" ] || [ "$(command -v carapace)" -nt "$_carapace_cache" ]; then
		mkdir -p "${_carapace_cache%/*}"
		carapace _carapace "$_shell" >"$_carapace_cache"
	fi
	. "$_carapace_cache"
	unset _carapace_cache
fi

# pyenv + pyenv-virtualenv (cached)
if command -v pyenv >/dev/null 2>&1; then
	export PYENV_VIRTUALENV_DISABLE_PROMPT=1
	_pyenv_cache="${XDG_CACHE_HOME:-$HOME/.cache}/pyenv_init.$_shell"
	if [ ! -f "$_pyenv_cache" ] || [ "$(command -v pyenv)" -nt "$_pyenv_cache" ]; then
		mkdir -p "${_pyenv_cache%/*}"
		{
			pyenv init -
			command pyenv virtualenv-init - 2>/dev/null
		} >"$_pyenv_cache"
	fi
	. "$_pyenv_cache"
	unset _pyenv_cache
fi

# pixi
if command -v pixi >/dev/null 2>&1; then
	eval "$(pixi completion --shell $_shell)"
fi

unset _shell

# conda
if command -v conda >/dev/null 2>&1; then
	eval "$(conda config --set changeps1 False)"
fi

# nvm (lazy-loaded)
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
	nvm() {
		unset -f nvm node npm npx
		. "$NVM_DIR/nvm.sh"
		nvm "$@"
	}
	node() {
		unset -f nvm node npm npx
		. "$NVM_DIR/nvm.sh"
		node "$@"
	}
	npm() {
		unset -f nvm node npm npx
		. "$NVM_DIR/nvm.sh"
		npm "$@"
	}
	npx() {
		unset -f nvm node npm npx
		. "$NVM_DIR/nvm.sh"
		npx "$@"
	}
fi
