#!/usr/bin/env bash
# Stow all directories

STOW_DIR="stow"
for f in $(basename -a ${STOW_DIR}/*) ; do
   stow -d ${STOW_DIR} -t $HOME -D "${f}" 2>/dev/null
done
