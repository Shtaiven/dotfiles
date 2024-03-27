#!/usr/bin/env bash
# Update the installed system

SCRIPT_DIR=$(dirname "$0")
SCRIPT_ARR=(
	"install-webi-packages.sh"
	"nvim.sh"
	"kitty.sh"
	"zellij.sh"
)

for script in ${SCRIPT_ARR[@]}; do
	source ${SCRIPT_DIR}/${script}
done
