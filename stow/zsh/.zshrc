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

# Multi-line editing: Prezto binds the arrows to history-substring-search,
# which always jumps to history — even mid-buffer in a multi-line command.
# These wrappers move within the buffer first and only search history from
# the top/bottom line (like zsh's default up-line-or-history).
if (( $+widgets[history-substring-search-up] )); then
  function up-line-or-substring-search() {
    if [[ $LBUFFER == *$'\n'* ]]; then
      zle up-line
    else
      zle history-substring-search-up
    fi
  }
  function down-line-or-substring-search() {
    if [[ $RBUFFER == *$'\n'* ]]; then
      zle down-line
    else
      zle history-substring-search-down
    fi
  }
  zle -N up-line-or-substring-search
  zle -N down-line-or-substring-search
  bindkey '^[[A' up-line-or-substring-search
  bindkey '^[OA' up-line-or-substring-search
  bindkey '^[[B' down-line-or-substring-search
  bindkey '^[OB' down-line-or-substring-search
fi

# Alt+Enter inserts a literal newline (matches the bash binding in .bashrc)
bindkey '^[^M' self-insert-unmeta

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

# Ghostty shell integration. Ghostty auto-injects it only into the shell it
# spawns, so a hand-launched `zsh` (also `exec zsh`, tmux, `sudo -E zsh`) gets
# no OSC 133 prompt marks and cursor-click-to-move does not work. Loaded last so
# Prezto's zle widgets are already in place. The entrypoint self-guards on
# _ghostty_state, so this is a no-op when Ghostty already injected it.
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
  source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi

# >>> dotfiles sentinel — nothing should be added below this line (pre-commit will flag installer additions) >>>
