#!/bin/sh
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

confirm() {
    printf "    Run: %s\n" "$1"
    printf "    Proceed? [y/N]: "
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
    if command -v curl >/dev/null 2>&1; then
        confirm "curl -fsSL https://pixi.sh/install.sh | sh"
        curl -fsSL https://pixi.sh/install.sh | sh
    else
        echo "    curl not found, installing via apt first"
        confirm "sudo apt-get update && sudo apt-get install -y curl"
        sudo apt-get update -qq && sudo apt-get install -y -qq curl
        confirm "curl -fsSL https://pixi.sh/install.sh | sh"
        curl -fsSL https://pixi.sh/install.sh | sh
    fi
    export PATH="$HOME/.pixi/bin:$PATH"
fi

echo "==> Installing stow"
if command -v stow >/dev/null 2>&1; then
    echo "    stow already installed"
else
    confirm "pixi global install --expose stow stow"
    pixi global install --expose stow stow
fi

echo "==> Installing curl"
if command -v curl >/dev/null 2>&1; then
    echo "    curl already installed"
else
    confirm "pixi global install curl"
    pixi global install curl
fi

echo "==> Linking dots to ~/.local/bin"
mkdir -p "$HOME/.local/bin"
ln -sf "$DOTFILES_DIR/scripts/dots" "$HOME/.local/bin/dots"

echo "==> Done"
echo "    Run 'dots list' to see available packages"
echo "    Run 'dots install <package>' to stow a package"
