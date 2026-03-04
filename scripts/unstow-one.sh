#!/usr/bin/env bash
# Stow all directories

STOW_DIR="stow"
TARGET_DIR=${HOME}
stow -d ${STOW_DIR} -t ${TARGET_DIR} -D $1 2>/dev/null
