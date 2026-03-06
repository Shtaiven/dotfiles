# Portable tool inits — sourced by both bash and zsh

# Detect current shell once
if [ -n "$ZSH_VERSION" ]; then _shell=zsh; elif [ -n "$BASH_VERSION" ]; then _shell=bash; fi

# bat as manpager
if command -v bat >/dev/null 2>&1; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
	export MANROFFOPT="-c"
elif command -v batcat >/dev/null 2>&1; then
	export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
	export MANROFFOPT="-c"
fi

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

# tmux wrapper: restore terminal state after tmux exits
if command -v tmux >/dev/null 2>&1; then
	tmux() {
		command tmux "$@"
		stty sane 2>/dev/null
	}

	# ssht — ssh with tmux config copied to remote (plugins stripped)
	ssht() {
		if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
			echo "Usage: ssht user@host"
			echo ""
			echo "SSH into a remote host and attach to (or create) a tmux session using"
			echo "your local tmux config. TPM plugins are stripped before copying so the"
			echo "remote does not attempt to bootstrap the plugin manager."
			return 0
		fi
		if [ -z "$1" ]; then
			echo "Usage: ssht user@host" >&2
			return 1
		fi
		local config hash remote_conf
		config=$(sed '/# plugins (TPM)/,$d' "$HOME/.tmux.conf")
		hash=$(printf '%s' "$config" | sha1sum | cut -c1-8)
		remote_conf="/tmp/.tmux-${hash}.conf"
		ssh "$1" "test -f $remote_conf" || printf '%s' "$config" | ssh "$1" "cat > $remote_conf"
		ssh -t "$1" "tmux -f $remote_conf new-session -A -s main"
	}
fi

# distant-install — install distant on a remote host for distant.nvim
# Usage: distant-install [--online] user@host
distant-install() {
	local online=0 host
	if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
		echo "Usage: distant-install [--online] user@host"
		echo ""
		echo "Install the distant server binary on a remote host for use with distant.nvim."
		echo ""
		echo "Options:"
		echo "  --online    Run the official install script on the remote (requires internet on remote)."
		echo "              Supports all architectures."
		echo ""
		echo "Default (no --online): detects remote OS/arch, downloads the correct prebuilt"
		echo "binary locally, and copies it over via scp. The remote needs no internet access."
		echo "Supports x86_64 and aarch64 on Linux and macOS."
		echo ""
		echo "Run once per remote, then use :DistantLaunch user@host from nvim to connect."
		return 0
	fi
	if [ "$1" = "--online" ]; then
		online=1
		shift
	fi
	host="$1"
	if [ -z "$host" ]; then
		echo "Usage: distant-install [--online] user@host" >&2
		return 1
	fi

	if [ "$online" = 1 ]; then
		ssh "$host" "curl -L https://sh.distant.dev | sh"
		return
	fi

	local os arch triple tmpfile
	os=$(ssh "$host" "uname -s" | tr '[:upper:]' '[:lower:]')
	arch=$(ssh "$host" "uname -m")
	case "$arch" in
	x86_64) arch="x86_64" ;;
	aarch64 | arm64) arch="aarch64" ;;
	*)
		echo "distant-install: $arch has no prebuilt binary — try: distant-install --online $host" >&2
		return 1
		;;
	esac
	case "$os" in
	linux) triple="${arch}-unknown-linux-musl" ;;
	darwin) triple="${arch}-apple-darwin" ;;
	*)
		echo "distant-install: unsupported OS: $os — try: distant-install --online $host" >&2
		return 1
		;;
	esac
	tmpfile=$(mktemp)
	curl -fsSL "https://github.com/chipsenkbeil/distant/releases/latest/download/distant-${triple}" -o "$tmpfile" || {
		rm "$tmpfile"
		return 1
	}
	ssh "$host" "mkdir -p ~/.local/bin"
	scp "$tmpfile" "$host:~/.local/bin/distant"
	ssh "$host" "chmod +x ~/.local/bin/distant"
	rm "$tmpfile"
	echo "distant installed on $host (~/.local/bin/distant)"
}

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
			pyenv init - "$_shell"
			command pyenv virtualenv-init - "$_shell" 2>/dev/null
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
