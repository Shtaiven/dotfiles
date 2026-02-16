#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Steven Eisinger <steven.a.eisinger@gmail.com>
#

# Source pixi at the top since there are programs added to our path that may be initialized below
export PATH="/home/steven/.pixi/bin:$PATH"

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# please alias
alias please='sudo $(fc -ln -1)'

# gearlever alias
if (( $+commands[flatpak] )) && flatpak info it.mijorus.gearlever &>/dev/null; then
  alias gearlever='flatpak run it.mijorus.gearlever'
fi

#
# exa
#
if (( $+commands[exa] )); then
  export EXA_COMMON_ARGS="--icons --color=auto"
  alias l="exa -1 $EXA_COMMON_ARGS"
  alias la="exa -a $EXA_COMMON_ARGS"
  alias ll="exa -lah $EXA_COMMON_ARGS"
  alias ls="exa $EXA_COMMON_ARGS"
  alias tree="exa --tree $EXA_COMMON_ARGS"
  unset EXA_COMMON_ARGS
fi

if (( $+commands[bat] )); then
  # Take default less args from zprofile for bat scrolling
  export BAT_PAGER="less $LESS"
  alias cat="bat --plain"
fi

#
# fd
#

if (( $+commands[fd] )); then
  # use fd as fzf default instead of find
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
# starship prompt customization
#

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

#
# zoxide
#

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

#
# pyenv and pyenv-virtualenv
#

if (( $+commands[pyenv] )); then
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

#
# conda
#

if (( $+commands[conda] )); then
  eval "$(conda config --set changeps1 False)"
fi

#
# kitty ssh alias
#

if [[ $TERM == "xterm-kitty" ]]; then
  alias ssh="kitty +kitten ssh"
fi

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

