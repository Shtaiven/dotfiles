#!/usr/bin/env bash

DOWNLOAD_DEST="${HOME}/.local"
INSTALL_DEST="${HOME}/.local/bin"
TARBALL_NAME="nvim-linux64"
TARBALL_EXT=".tar.gz"
TAR_ARGS="xzvf"
BIN_PATH="${TARBALL_NAME}/bin/nvim"
INSTALL_NAME="nvim"

# Make sure that ~/.local/bin exists
mkdir -p ${DOWNLOAD_DEST}
mkdir -p ${INSTALL_DEST}

# Install pre-built binary of nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/${TARBALL_NAME}${TARBALL_EXT}

# Extract and untar, move to the specified download folder, and remove the download
tar ${TAR_ARGS} ${TARBALL_NAME}${TARBALL_EXT}
mv -f ${TARBALL_NAME} ${DOWNLOAD_DEST}/${TARBALL_NAME}
rm -rf ${TARBALL_NAME}${TARBALL_EXT}

# Link the file into the specified install folder
ln -sf ${DOWNLOAD_DEST}/${BIN_PATH} ${INSTALL_DEST}/${INSTALL_NAME}

# Give it executable permission
chmod +x ${INSTALL_DEST}/${INSTALL_NAME}

