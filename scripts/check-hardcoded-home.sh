#!/bin/sh
found=0
for f in "$@"; do
  matches=$(grep -nE '/home/[[:alnum:]_-]+' "$f")
  if [ -n "$matches" ]; then
    echo "$f: hardcoded /home/username path (use \$HOME instead):"
    echo "$matches" | sed 's/^/  /'
    found=1
  fi
done
exit $found
