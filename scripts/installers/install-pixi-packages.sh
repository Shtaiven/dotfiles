#!/usr/bin/env bash
# Install pixi if not installed already, then install listed packages
if ! command -v pixi >/dev/null; then
	echo "pixi not found. Installing pixi..."
	source $(dirname "$0")/pixi.sh
fi

cat $(dirname "$0")/pixi-packages.txt | xargs pixi global install -c conda-forge
