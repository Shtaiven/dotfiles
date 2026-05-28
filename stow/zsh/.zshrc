#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Steven Eisinger <steven.a.eisinger@gmail.com>
#

# Bash-style globbing: pass unmatched globs through as literals
setopt NO_NOMATCH

# Local specific extensions (sourced before Prezto so fpath edits apply pre-compinit)
if [[ -d "$HOME/.zsh.d" ]]; then
  for f in "$HOME"/.zsh.d/*(N); do
    [[ -f "$f" ]] && source "$f"
  done
  unset f
fi

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
# (N-.) = NULL_GLOB + follow symlinks + regular files only — skips broken symlinks
for f in "$HOME"/.shell.d/*.sh(N-.); do
  source "$f"
done
unset f

# zoxide uses _files -/ which emits multiple tag groups, causing duplicate rows
# when group-name '' is set (e.g. by Prezto). _path_files -/ avoids this.
# See: https://github.com/ajeetdsouza/zoxide/issues/491
if (( ${+commands[zoxide]} )); then
  function __zoxide_z_complete() {
    [[ "${#words[@]}" -eq "${CURRENT}" ]] || return
    if [[ "${#words[@]}" -eq 2 ]]; then
      _path_files -/
    elif [[ "${words[-1]}" == '' ]]; then
      local result
      if result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -i -- ${words[2,-1]})"; then
        __zoxide_result="${result}"
      else
        __zoxide_result=''
      fi
      \builtin printf '\e[5n'
    fi
  }
fi

# Set terminal title to current directory (updates tmux pane_title via OSC 0)
function _set_title_to_dir() { print -Pn '\e]0;%~\a' }
add-zsh-hook precmd _set_title_to_dir

# >>> dotfiles sentinel — nothing should be added below this line (pre-commit will flag installer additions) >>>
