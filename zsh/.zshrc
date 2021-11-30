#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Steven Eisinger <steven.a.eisinger@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize prompt using starship
eval "$(starship init zsh)"

#
# zoxide
#

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

#
# mujoco
#

if [[ -f /usr/lib/x86_64-linux-gnu/libGLEW.so ]]; then 
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/steven/.mujoco/mujoco200/bin
  export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libGLEW.so
fi

#
# pyenv and pyenv-virtualenv
#

if (( $+commands[pyenv] )); then
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi
