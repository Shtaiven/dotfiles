#!/bin/sh
# Verify the dotfiles sentinel is the last non-blank line of each file.
# Catches installer-style additions (LM Studio CLI, nvm, conda, etc.) that
# append PATH/init blocks to shell rc files.
sentinel='# >>> dotfiles sentinel'
found=0
for f in "$@"; do
  if ! grep -qF "$sentinel" "$f"; then
    echo "$f: missing sentinel comment ('$sentinel ...')"
    found=1
    continue
  fi
  last=$(grep -nv '^[[:space:]]*$' "$f" | tail -n 1)
  case "$last" in
    *"$sentinel"*) ;;
    *)
      echo "$f: content found below sentinel — move it above, or remove it:"
      awk -v s="$sentinel" 'index($0,s){flag=1; next} flag && NF{print "  " NR": "$0}' "$f"
      found=1
      ;;
  esac
done
exit $found
