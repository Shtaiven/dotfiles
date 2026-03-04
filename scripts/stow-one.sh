#!/usr/bin/env bash
# Stow one directory

STOW_DIR="stow"
TARGET_DIR=${HOME}
stow -d ${STOW_DIR} -t ${TARGET_DIR} -R $1
