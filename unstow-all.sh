#!/usr/bin/env bash
# Stow all directories, excluding extras

for f in */ ; do
    if [ "${f%*/}" = "extras" ] ; then
        continue
    elif [ -d "$f" ] ; then
        stow -D "${f%*/}" 2>/dev/null
    fi
done
