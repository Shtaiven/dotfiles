#!/usr/bin/env bash
# Install pre-built binary of nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage

# Move and rename nvim to PATH (assuming ~/.local/bin is in
# your system-wide PATH)
mv -f nvim.appimage ~/.local/bin/nvim

# Give it executable permission
chmod +x ~/.local/bin/nvim

