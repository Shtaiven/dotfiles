#!/usr/bin/env bash

set -e

DOWNLOAD_DEST="${HOME}/.local"
INSTALL_DEST="${HOME}/.local/bin"
TARBALL_NAME="zellij-x86_64-unknown-linux-musl"
TARBALL_EXT=".tar.gz"
TAR_ARGS="xzvf"
BIN_PATH="zellij"
INSTALL_NAME="zellij"

# Make sure that ~/.local/bin exists
mkdir -p ${DOWNLOAD_DEST}
mkdir -p ${INSTALL_DEST}

# Install pre-built binary of nvim
curl -LO https://github.com/zellij-org/zellij/releases/latest/download/${TARBALL_NAME}${TARBALL_EXT}

# Extract and untar, move to the specified download folder, and remove the download
tar ${TAR_ARGS} ${TARBALL_NAME}${TARBALL_EXT} 1>/dev/null
rm -rf ${DOWNLOAD_DEST}/${TARBALL_NAME} 2>/dev/null
mv -f ${BIN_PATH} ${INSTALL_DEST}/${INSTALL_NAME}
rm -f ${TARBALL_NAME}${TARBALL_EXT}

# Give it executable permission
chmod +x ${INSTALL_DEST}/${INSTALL_NAME}

