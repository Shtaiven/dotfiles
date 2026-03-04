# Portable aliases — sourced by both bash and zsh

# please — re-run last command with sudo
if [ -n "$ZSH_VERSION" ]; then
	alias please='sudo $(fc -ln -1)'
else
	alias please='sudo $(fc -ln -1)'
fi

# gearlever — flatpak guard
if command -v flatpak >/dev/null 2>&1 && flatpak info it.mijorus.gearlever >/dev/null 2>&1; then
	alias gearlever='flatpak run it.mijorus.gearlever'
fi

# bat — normalize to 'bat' (Debian/Ubuntu ship it as batcat)
command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1 && alias bat=batcat

if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
	if command -v bat >/dev/null 2>&1; then _bat_bin=bat; else _bat_bin=batcat; fi
	export BAT_PAGER="less $LESS"
	alias cat="bat --plain"
	export MANPAGER="sh -c 'col -bx | $_bat_bin --language=man --plain'"
	unset _bat_bin
fi

# kitty ssh
if [ "$TERM" = "xterm-kitty" ]; then
	alias ssh="kitty +kitten ssh"
fi

# peon-ping quick controls
[ -f /home/steven/.claude/hooks/peon-ping/peon.sh ] && alias peon="bash /home/steven/.claude/hooks/peon-ping/peon.sh"
[ -f /home/steven/.claude/hooks/peon-ping/completions.bash ] && source /home/steven/.claude/hooks/peon-ping/completions.bash

# nvim
if command -v nvim >/dev/null 2>&1; then
	alias vi=nvim
	alias vim=nvim
fi

# zoxide — override cd
if command -v zoxide >/dev/null 2>&1; then
	alias cd=z
fi

# dircolors + color aliases
if [ -x /usr/bin/dircolors ]; then
	if [ -r "$HOME/.dircolors" ]; then
		eval "$(dircolors -b "$HOME/.dircolors")"
	else
		eval "$(dircolors -b)"
	fi
	alias ls='ls --color=auto'
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ls aliases (plain ls, no exa)
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# lesspipe
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# alert — notify after long running commands (e.g. sleep 10; alert)
if command -v notify-send >/dev/null 2>&1; then
	alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi
