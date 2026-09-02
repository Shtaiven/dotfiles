# If not running interactively, don't do anything
# shellcheck shell=bash
[[ $- != *i* ]] && return

# History
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=5000
# Save multi-line commands as one history entry with embedded newlines, so a
# recalled command is a single editable buffer
shopt -s cmdhist lithist

# UP and DOWN do partial history search
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Alt+Enter inserts a literal newline: build multi-line commands in one
# editable buffer instead of the PS2 continuation prompt (readline can't
# edit previous lines once at PS2). Enter still runs the whole buffer.
bind '"\e\C-m": "\C-v\C-j"'

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
	# Last three path components, ~-abbreviated: mirrors zsh's
	# %(4~|…/%3~|%~) in .zshrc so both shells title the same way.
	__truncate_path() {
		local p="${1/#$HOME/\~}"
		local IFS=/
		local -a parts
		read -ra parts <<<"${p#/}"
		if (( ${#parts[@]} > 3 )); then
			printf '…/%s/%s/%s' "${parts[-3]}" "${parts[-2]}" "${parts[-1]}"
		else
			printf '%s' "$p"
		fi
	}
	# Command name for the title: basename of the first word that is not an env
	# assignment, sudo/ssh, or a flag. Mirrors Prezto's terminal module
	# (${${2[(wr)^(*=*|sudo|ssh|-*)]}:t}), whose window title is untruncated, so
	# `sudo VAR=1 /usr/bin/nvim -f x` titles as `nvim` in both shells. Prezto
	# leaves the title empty when no word qualifies (e.g. a bare `sudo`); fall
	# back to the first word instead.
	__title_cmd() {
		local -a words
		read -ra words <<<"$1"
		local w
		for w in "${words[@]}"; do
			case "$w" in
			*=* | sudo | ssh | -*) continue ;;
			esac
			printf '%s' "${w##*/}"
			return
		done
		printf '%s' "${words[0]##*/}"
	}
	__title_skip=true
	__prompt_begin() { __title_skip=true; }
	__prompt_end()   { __set_title "$(__title_prefix)$(__truncate_path "$PWD")"; __title_skip=false; }
	__preexec_title() {
		[[ "$__title_skip" == true ]] && return
		[[ "${COMP_LINE+x}" ]] && return
		local cmd="${BASH_COMMAND}"
		[[ "$cmd" == __* || "$cmd" == trap* || "$cmd" == printf* ]] && return
		__set_title "$(__title_prefix)$(__title_cmd "$cmd")"
	}
	# Re-sourcing this rc must not wrap PROMPT_COMMAND again; skipping also keeps
	# hooks appended after the first wrap (e.g. Ghostty's) outside the wrapper.
	if [[ "${PROMPT_COMMAND[*]:-}" != *"__prompt_begin"* ]]; then
		PROMPT_COMMAND="__prompt_begin;${PROMPT_COMMAND:-:};__prompt_end"
	fi
	trap '__preexec_title' DEBUG
	;;
esac

# Ghostty prompt marking (OSC 133) for cursor-click-to-move.
# On bash < 5.3 Ghostty runs its preexec hook in a command substitution, so
# _ghostty_executing never returns to 1 and its precmd stops re-marking PS1
# after the first prompt. Harmless normally (the marks leak into PS1 and stay),
# but starship rebuilds PS1 every prompt, so they vanish. Re-arm the flag.
# Ghostty defines its own functions only after it sources this rc, so there is
# nothing to probe for here; the flag test in the body is the real guard - unset
# means the integration never loaded and this is a no-op.
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]] &&
	((BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 3))); then
	__ghostty_rearm() { [[ "${_ghostty_executing-}" == 0 ]] && _ghostty_executing=1; return 0; }
	# Re-sourcing this rc must not append the hook twice.
	if [[ "${PROMPT_COMMAND[*]:-}" != *"__ghostty_rearm"* ]]; then
		PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__ghostty_rearm"
	fi
fi

# >>> dotfiles sentinel — nothing should be added below this line (pre-commit will flag installer additions) >>>
