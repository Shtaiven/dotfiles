#!/bin/sh
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

confirm() {
    printf "%s [y/N]: " "$1"
    read -r answer
    case "$answer" in
        y|Y|yes|YES) return 0 ;;
        *) echo "Aborted."; exit 1 ;;
    esac
}

echo "==> Installing pixi"
if command -v pixi >/dev/null 2>&1; then
    echo "    pixi already installed"
else
    confirm "    pixi not found. Install it?"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://pixi.sh/install.sh | sh
    else
        echo "    curl not found, installing via apt first"
        confirm "    Install curl via apt?"
        sudo apt-get update -qq && sudo apt-get install -y -qq curl
        curl -fsSL https://pixi.sh/install.sh | sh
    fi
    export PATH="$HOME/.pixi/bin:$PATH"
fi

echo "==> Installing stow"
if command -v stow >/dev/null 2>&1; then
    echo "    stow already installed"
else
    confirm "    stow not found. Install it globally via pixi?"
    pixi global install stow
fi

echo "==> Installing curl"
if command -v curl >/dev/null 2>&1; then
    echo "    curl already installed"
else
    confirm "    curl not found. Install it globally via pixi?"
    pixi global install curl
fi

echo "==> Linking dots to ~/.local/bin"
mkdir -p "$HOME/.local/bin"
ln -sf "$DOTFILES_DIR/scripts/dots" "$HOME/.local/bin/dots"

echo "==> Done"
echo "    Run 'dots packages' to see available packages"
echo "    Run 'dots install <package>' to stow a package"
