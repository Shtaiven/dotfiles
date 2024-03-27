#!/usr/bin/env bash
# Stow all directories

STOW_DIR="stow"
TARGET_DIR=${HOME}
for f in $(basename -a ${STOW_DIR}/*); do
	stow -d ${STOW_DIR} -t ${TARGET_DIR} -R "${f}"
done
