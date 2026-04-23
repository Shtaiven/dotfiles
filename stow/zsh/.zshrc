#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Steven Eisinger <steven.a.eisinger@gmail.com>
#

# Bash-style globbing: pass unmatched globs through as literals
setopt NO_NOMATCH

# Source Prezto (installed by: dots install zsh)
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Prevent autosuggestions from interfering with repeated tab completion
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(expand-or-complete expand-or-complete-prefix)

# Completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zcompcache"

# Secrets (not tracked in dotfiles)
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"

# Source shared shell config (portable bash/zsh)
for f in "$HOME"/.shell.d/*.sh(N); do
  source "$f"
done
unset f

# Set terminal title to current directory (updates tmux pane_title via OSC 0)
function _set_title_to_dir() { print -Pn '\e]0;%~\a' }
add-zsh-hook precmd _set_title_to_dir
