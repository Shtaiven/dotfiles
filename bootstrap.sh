#!/bin/sh
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

confirm() {
    printf "    Run: %s\n" "$1"
    printf "    Proceed? [y/N]: "
    read -r answer
    case "$answer" in
        y|Y|yes|YES) return 0 ;;
        *) echo "    Skipped."; return 1 ;;
    esac
}

echo "==> Installing pixi"
if command -v pixi >/dev/null 2>&1; then
    echo "    pixi already installed"
else
    if command -v curl >/dev/null 2>&1; then
        confirm "curl -fsSL https://pixi.sh/install.sh | sh" &&
            curl -fsSL https://pixi.sh/install.sh | sh
    elif command -v wget >/dev/null 2>&1; then
        confirm "wget -qO- https://pixi.sh/install.sh | sh" &&
            wget -qO- https://pixi.sh/install.sh | sh
    else
        echo "    Neither curl nor wget found — install one manually"
    fi
    export PATH="$HOME/.pixi/bin:$PATH"
fi

echo "==> Installing curl"
if command -v curl >/dev/null 2>&1; then
    echo "    curl already installed"
elif command -v pixi >/dev/null 2>&1; then
    confirm "pixi global install curl" &&
        pixi global install curl
elif command -v apt-get >/dev/null 2>&1; then
    confirm "sudo apt-get install -y curl" &&
        sudo apt-get install -y -qq curl
else
    echo "    Could not install curl — install it manually"
fi

echo "==> Installing stow"
if command -v stow >/dev/null 2>&1; then
    echo "    stow already installed"
elif command -v pixi >/dev/null 2>&1 && confirm "pixi global install --expose stow stow"; then
    pixi global install --expose stow stow || {
        echo "    pixi install failed, falling back to apt"
        confirm "sudo apt-get install -y stow" &&
            sudo apt-get install -y -qq stow
    }
elif command -v apt-get >/dev/null 2>&1; then
    confirm "sudo apt-get install -y stow" &&
        sudo apt-get install -y -qq stow
else
    echo "    Could not install stow — install it manually"
fi

echo "==> Linking dots to ~/.local/bin"
mkdir -p "$HOME/.local/bin"
ln -sf "$DOTFILES_DIR/scripts/dots" "$HOME/.local/bin/dots"

echo "==> Done"
echo "    Run 'dots list' to see available packages"
echo "    Run 'dots install <package>' to stow a package"
