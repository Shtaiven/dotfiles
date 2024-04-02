# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=5000

# UP and DOWN do partial history search
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# current directory as tab title
# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm-kitty)
  export PROMPT_COMMAND='echo -ne "\033]0;$(basename ${PWD})\007"'
  ;;
*)
  ;;
esac

# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [[ -x /usr/bin/dircolors ]]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#
# cargo
#
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

#
# fd
#
if [[ -x "$(command -v fd)" ]]; then
  export FZF_CTRL_T_COMMAND="fd --hidden --follow --exclude \".git\" . $HOME"
  export FZF_ALT_C_COMMAND="fd -t d --hidden --follow --exclude \".git\" . $HOME"

  _fzf_compgen_path() {
    fd --type f --hidden --follow --exclude .git . "$1"
  }
  _fzf_compgen_dir() {
    fd --type d . "$1"
  }
fi

#
# bat
#
export BAT_PAGER="less $LESS"
[[ -x $(command -v batcat) ]] && alias bat=batcat

#
# pyenv
#
if [[ -x "$(command -v pyenv)" ]]; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

#
# zoxide
#
if [[ -x $(command -v zoxide) ]]; then
  eval "$(zoxide init bash)"
  alias cd=z
fi

#
# starship
#
[[ -x $(command -v starship) ]] && eval "$(starship init bash)"

#
# nvim
#
if [[ -x $(command -v nvim) ]]; then
  export EDITOR=nvim
  export VISUAL=nvim
  alias vi=nvim
  alias vim=nvim
fi

# Generated for envman. Do not edit.
[[ -s "$HOME/.config/envman/load.sh" ]] && source "$HOME/.config/envman/load.sh"

# Alias definitions
if [[ -f "$HOME/.bash_aliases" ]]; then
  source "$HOME/.bash_aliases"
fi

# Local specific extensions
if [[ -d "$HOME/.bash.d" ]]; then
  for f in $HOME/.bash.d/*; do
    if [[ -f $f ]]; then
      source "$f"
    fi
  done
fi
