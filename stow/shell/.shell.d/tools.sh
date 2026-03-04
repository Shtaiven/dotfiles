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

# starship
command -v starship >/dev/null 2>&1 && eval "$(starship init $_shell)"

# zoxide
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init $_shell)"

# carapace
command -v carapace >/dev/null 2>&1 && source <(carapace _carapace "$_shell")

unset _shell

# pyenv + pyenv-virtualenv
if command -v pyenv >/dev/null 2>&1; then
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# conda
if command -v conda >/dev/null 2>&1; then
  eval "$(conda config --set changeps1 False)"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
