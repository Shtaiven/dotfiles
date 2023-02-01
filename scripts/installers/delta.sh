#!/usr/bin/env bash

DELTA_VERSION="0.15.1"
DOWNLOAD_DEST="${HOME}/.local"
INSTALL_DEST="${HOME}/.local/bin"
TARBALL_NAME="delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu"
TARBALL_EXT=".tar.gz"
TAR_ARGS="xzvf"
BIN_PATH="${TARBALL_NAME}/delta"
INSTALL_NAME="delta"

# Make sure that ~/.local/bin exists
mkdir -p ${DOWNLOAD_DEST}
mkdir -p ${INSTALL_DEST}

# Install pre-built binary of nvim
curl -LO "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/${TARBALL_NAME}${TARBALL_EXT}"

# Extract and untar, move to the specified download folder, and remove the download
tar ${TAR_ARGS} ${TARBALL_NAME}${TARBALL_EXT} 1>/dev/null
rm -rf ${DOWNLOAD_DEST}/${TARBALL_NAME} 2>/dev/null
mv -f ${TARBALL_NAME} ${DOWNLOAD_DEST}/${TARBALL_NAME}
rm -rf ${TARBALL_NAME}${TARBALL_EXT}

# Link the file into the specified install folder
ln -sf ${DOWNLOAD_DEST}/${BIN_PATH} ${INSTALL_DEST}/${INSTALL_NAME}

# Give it executable permission
chmod +x ${INSTALL_DEST}/${INSTALL_NAME}

