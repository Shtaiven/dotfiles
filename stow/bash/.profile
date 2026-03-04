# ~/.profile: executed by the command interpreter for login shells.

# if running bash
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# Shared login environment (portable sh)
if [ -d "$HOME/.profile.d" ]; then
  for f in "$HOME"/.profile.d/*.sh; do
    [ -f "$f" ] && . "$f"
  done
  unset f
fi
