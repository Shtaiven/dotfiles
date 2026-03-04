#!/usr/bin/env bash
# Unstow all directories

STOW_DIR="stow"
TARGET_DIR=${HOME}
for f in $(basename -a ${STOW_DIR}/*); do
	stow -d ${STOW_DIR} -t ${TARGET_DIR} -D "${f}" 2>/dev/null
done
