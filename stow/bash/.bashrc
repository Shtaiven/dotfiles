# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# History
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=5000

# UP and DOWN do partial history search
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# check the window size after each command
shopt -s checkwinsize

# Programmable completion
if ! shopt -oq posix; then
	if [[ -f /usr/share/bash-completion/bash_completion ]]; then
		. /usr/share/bash-completion/bash_completion
	elif [[ -f /etc/bash_completion ]]; then
		. /etc/bash_completion
	fi
fi

# Secrets (not tracked in dotfiles)
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"

# Shared shell config (portable bash/zsh)
if [[ -d "$HOME/.shell.d" ]]; then
	for f in "$HOME"/.shell.d/*.sh; do
		[[ -f "$f" ]] && source "$f"
	done
	unset f
fi

# Local specific extensions
if [[ -d "$HOME/.bash.d" ]]; then
	for f in "$HOME"/.bash.d/*; do
		[[ -f "$f" ]] && source "$f"
	done
	unset f
fi

# Window/tab title (mimics zprezto terminal module behavior)
# Sets title to "user@host: /dir" at prompt, "user@host: command" while running
# Must be after shell.d sourcing so we can append to starship's PROMPT_COMMAND
case "$TERM" in
xterm* | rxvt* | screen* | tmux*)
	__set_title() { printf '\e]0;%s\a' "$1"; }
	__title_prefix() { [[ -n "$SSH_TTY" ]] && printf '%s' "${USER}@${HOSTNAME%%.*}: "; }
	__truncate_path() {
		local p="${1/#$HOME/\~}"
		(( ${#p} > 15 )) && p="...${p: -12}"
		printf '%s' "$p"
	}
	__truncate_cmd() {
		local c="$1"
		(( ${#c} > 15 )) && c="${c:0:12}..."
		printf '%s' "$c"
	}
	__prompt_title() {
		__title_skip=true
		__set_title "$(__title_prefix)$(__truncate_path "$PWD")"
		__title_skip=false
	}
	__title_skip=true
	__preexec_title() {
		[[ "$__title_skip" == true ]] && return
		[[ "${COMP_LINE+x}" ]] && return
		local cmd="${BASH_COMMAND}"
		[[ "$cmd" == __* || "$cmd" == trap* || "$cmd" == printf* ]] && return
		__set_title "$(__title_prefix)$(__truncate_cmd "$cmd")"
	}
	PROMPT_COMMAND="__prompt_title;${PROMPT_COMMAND:-:}"
	trap '__preexec_title' DEBUG
	;;
esac
