#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Steven Eisinger <steven.a.eisinger@gmail.com>
#

# pixi
export PATH="/home/steven/.pixi/bin:$PATH"

# Bootstrap Prezto if not present
if [[ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]]; then
  echo "Prezto not found. Installing..."
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi

# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Source shared shell config (portable bash/zsh)
for f in "$HOME"/.shell.d/*.sh(N); do
  source "$f"
done
unset f
