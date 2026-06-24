#!/usr/bin/env bash
#
# kb-kill installer — sets up the root daemon + the user tray.
#
# Run as your normal user; it uses sudo for the root parts:
#   ./install.sh
#
# Idempotent — re-run it to redeploy after editing the daemon code.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
USER_NAME="${SUDO_USER:-$USER}"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
CONFIG="$USER_HOME/.config/kb-kill/kb-kill.toml"

say()  { printf '\033[0;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }

# --------------------------------------------------------------------------- #
# User side (no root)
# --------------------------------------------------------------------------- #
say "Installing user-side components for $USER_NAME"

mkdir -p "$USER_HOME/.local/bin"
# kb-kill itself isn't symlinked here: the root install puts it at
# /usr/local/bin/kb-kill (already on PATH), so `sudo kb-kill detect` finds it.
# Remove any stale link a previous installer left, which would shadow it.
rm -f "$USER_HOME/.local/bin/kb-kill"
# -n (no-dereference): replace an existing symlink itself rather than following
# it (e.g. an old link pointing at the project dir).
ln -sfn "$PROJECT_DIR/kb-kill-tray" "$USER_HOME/.local/bin/kb-kill-tray"

# Config: install the example only if absent; otherwise ask before overwriting.
mkdir -p "$USER_HOME/.config/kb-kill"
if [ ! -e "$CONFIG" ]; then
  cp "$PROJECT_DIR/kb-kill.toml" "$CONFIG"
  say "Installed default config -> $CONFIG"
else
  printf 'kb-kill.toml already exists at %s. Overwrite? [y/N] ' "$CONFIG"
  read -r reply
  if [ "$reply" = "y" ] || [ "$reply" = "Y" ]; then
    if [ -L "$CONFIG" ]; then
      warn "Overwriting a symlink detaches it from your dotfiles (stow)."
    fi
    cp "$PROJECT_DIR/kb-kill.toml" "$CONFIG"
    say "Overwrote config -> $CONFIG"
  else
    say "Kept existing config."
  fi
fi

# Tray user service.
mkdir -p "$USER_HOME/.config/systemd/user"
ln -sfn "$PROJECT_DIR/kb-kill-tray.service" \
        "$USER_HOME/.config/systemd/user/kb-kill-tray.service"
systemctl --user enable --now kb-kill-tray.service 2>/dev/null \
  || warn "Could not enable kb-kill-tray (no user session bus here?). Enable later: systemctl --user enable --now kb-kill-tray"

# --------------------------------------------------------------------------- #
# Root side (sudo): daemon binary, icons, hardened system unit
# --------------------------------------------------------------------------- #
say "Installing the root daemon (sudo)"

sudo install -D -m0755 -o root -g root "$PROJECT_DIR/kb-kill" /usr/local/bin/kb-kill
sudo install -d -m0755 /usr/local/share/kb-kill/icons
sudo install -m0644 "$PROJECT_DIR"/icons/*.svg /usr/local/share/kb-kill/icons/

# Render the system unit with this user's config path, then install it.
TMP_UNIT="$(mktemp)"
sed "s#@CONFIG@#$CONFIG#g" "$PROJECT_DIR/kb-kill.service" > "$TMP_UNIT"
sudo install -m0644 -o root -g root "$TMP_UNIT" /etc/systemd/system/kb-kill.service
rm -f "$TMP_UNIT"

# Replace any old per-user kb-kill service to avoid two grabbers (and clean up
# the stale unit symlink left by the previous stow-managed install).
systemctl --user disable --now kb-kill.service 2>/dev/null || true
rm -f "$USER_HOME/.config/systemd/user/kb-kill.service"
systemctl --user daemon-reload 2>/dev/null || true

sudo systemctl daemon-reload
sudo systemctl enable --now kb-kill.service
say "kb-kill system service: $(systemctl is-active kb-kill.service)"

# --------------------------------------------------------------------------- #
# Follow-ups
# --------------------------------------------------------------------------- #
cat <<EOF

Done. Two manual follow-ups for the full security benefit:

  1) Remove yourself from the 'input' group so no ordinary user process can read
     keyboards anymore (only the sandboxed root daemon):
         sudo gpasswd -d $USER_NAME input
     Then log out and back in. (Verify nothing else you use needs it first.)

  2) After editing the daemon code, re-run this installer to redeploy:
         sudo true && $PROJECT_DIR/install.sh

Note: 'kb-kill detect' / 'monitor' now need sudo (you've left the input group).
EOF
