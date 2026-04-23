#!/bin/sh
command -v zsh >/dev/null 2>&1 || exit 0
exec zsh -n "$@"
