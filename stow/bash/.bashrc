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

# current directory as tab title
case "$TERM" in
xterm-kitty)
  export PROMPT_COMMAND='echo -ne "\033]0;$(basename ${PWD})\007"'
  ;;
*)
  ;;
esac

# Alias definitions
if [[ -f "$HOME/.bash_aliases" ]]; then
  source "$HOME/.bash_aliases"
fi

# Programmable completion
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi

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
