#!/usr/bin/env bash
#
# Build Aseprite and install it into a user-local prefix (no root).
#
# Usage:
#   ./install-local.sh              # build + install to ~/.local
#   ./install-local.sh --no-build   # install only, reuse existing build
#   ./install-local.sh --uninstall  # remove everything this script installs
#
# Env overrides:
#   PREFIX=~/.local     install prefix
#   BUILD_DIR=build     build directory (relative to repo root or absolute)
#
# Why this exists instead of `cmake --install "$BUILD_DIR"`:
#
#   1. Only the `aseprite` target is built, but a top-level install runs *every*
#      subproject's install rules -- including libarchive CLI tools (bsdunzip &
#      co.) that were never compiled. third_party is installed before src, so a
#      full install aborts on the missing binaries and never reaches Aseprite.
#      We therefore install the src/ and src/desktop/ subtrees only.
#
#   2. build.sh configures without -DENABLE_DESKTOP_INTEGRATION, so a freshly
#      recreated build dir silently reverts to the `off` default and the .desktop
#      / mime / thumbnailer install rules disappear. We re-assert it every run.
#
#   3. No CMake rule installs the application icon, even though aseprite.desktop
#      and mime/aseprite.xml both reference `Icon=aseprite`. We install it here.

set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
BUILD_DIR="${BUILD_DIR:-build}"
ICON_SIZES=(16 20 24 28 32 48 64 128 256)

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_root"

[[ -f EULA.txt && -f .gitmodules ]] || { echo "error: run from the Aseprite clone" >&2; exit 1; }
[[ "$BUILD_DIR" = /* ]] || BUILD_DIR="$repo_root/$BUILD_DIR"
PREFIX="${PREFIX/#\~/$HOME}"

say() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }

# Every path this script creates, so --uninstall is an exact inverse.
installed_paths() {
  echo "$PREFIX/bin/aseprite"
  echo "$PREFIX/bin/aseprite-thumbnailer"
  echo "$PREFIX/share/aseprite"
  echo "$PREFIX/share/applications/aseprite.desktop"
  echo "$PREFIX/share/mime/packages/aseprite.xml"
  echo "$PREFIX/share/thumbnailers/aseprite.thumbnailer"
  for s in "${ICON_SIZES[@]}"; do
    echo "$PREFIX/share/icons/hicolor/${s}x${s}/apps/aseprite.png"
  done
}

refresh_caches() {
  command -v update-desktop-database >/dev/null && \
    update-desktop-database "$PREFIX/share/applications" 2>/dev/null || true
  command -v update-mime-database >/dev/null && \
    update-mime-database "$PREFIX/share/mime" 2>/dev/null || true
  command -v gtk-update-icon-cache >/dev/null && \
    gtk-update-icon-cache -f -t "$PREFIX/share/icons/hicolor" 2>/dev/null || true
}

if [[ "${1:-}" == "--uninstall" ]]; then
  say "Removing Aseprite from $PREFIX"
  while read -r p; do
    [[ -e "$p" ]] && rm -rf "$p" && echo "  removed $p"
  done < <(installed_paths)
  # Prune dirs we may have created, but only while genuinely empty.
  for d in "$PREFIX"/share/icons/hicolor/*/apps "$PREFIX"/share/icons/hicolor/* \
           "$PREFIX/share/thumbnailers" "$PREFIX/share/icons/hicolor" "$PREFIX/share/icons"; do
    [[ -d "$d" ]] && rmdir "$d" 2>/dev/null || true
  done
  refresh_caches
  say "Done"
  exit 0
fi

# ---------------------------------------------------------------- configure --
say "Configuring $BUILD_DIR"

cmake_args=(-DENABLE_DESKTOP_INTEGRATION=ON)

if [[ ! -f "$BUILD_DIR/CMakeCache.txt" ]]; then
  # Fresh build dir: we must supply Skia ourselves. build.sh normally downloads
  # it and records the location under .build/<branch>_skia_dir.
  skia_dir=""
  for f in "$repo_root"/.build/*_skia_dir; do
    [[ -f "$f" ]] && skia_dir="$(cat "$f")" && break
  done
  if [[ -z "$skia_dir" || ! -d "$skia_dir" ]]; then
    echo "error: no Skia found. Run ./build.sh once to download it, then re-run this." >&2
    exit 1
  fi
  skia_lib="$skia_dir/out/Release-$(uname -m | sed 's/x86_64/x64/')"
  [[ -d "$skia_lib" ]] || { echo "error: missing $skia_lib" >&2; exit 1; }
  echo "  Skia: $skia_dir"
  cmake_args+=(-G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLAF_BACKEND=skia
               -DSKIA_DIR="$skia_dir" -DSKIA_LIBRARY_DIR="$skia_lib")
fi

# Re-asserted every run: build.sh resets ENABLE_DESKTOP_INTEGRATION to off.
cmake -B "$BUILD_DIR" -S "$repo_root" "${cmake_args[@]}" >/dev/null
echo "  ENABLE_DESKTOP_INTEGRATION=ON"

# -------------------------------------------------------------------- build --
if [[ "${1:-}" != "--no-build" ]]; then
  say "Building"
  cmake --build "$BUILD_DIR" -- aseprite
fi

[[ -x "$BUILD_DIR/bin/aseprite" ]] || { echo "error: $BUILD_DIR/bin/aseprite missing" >&2; exit 1; }

# ------------------------------------------------------------------ install --
say "Installing to $PREFIX"

# src/ only -- a top-level install dies in third_party (see header comment).
cmake --install "$BUILD_DIR/src"         --prefix "$PREFIX" >/dev/null
cmake --install "$BUILD_DIR/src/desktop" --prefix "$PREFIX" >/dev/null

# src/tga installs a static lib + header unconditionally; Aseprite is statically
# linked and needs neither, so don't leave them in the prefix.
rm -f "$PREFIX/lib/libtga-lib.a" "$PREFIX/include/tga.h"
rmdir "$PREFIX/lib" "$PREFIX/include" 2>/dev/null || true

# No CMake rule installs the icon that aseprite.desktop and the mime type name.
for s in "${ICON_SIZES[@]}"; do
  install -Dm644 "$repo_root/data/icons/ase$s.png" \
    "$PREFIX/share/icons/hicolor/${s}x${s}/apps/aseprite.png"
done

refresh_caches

# ------------------------------------------------------------------- verify --
say "Verifying"
missing=0
while read -r p; do
  if [[ -e "$p" ]]; then printf '  ok      %s\n' "$p"
  else printf '  MISSING %s\n' "$p"; missing=1; fi
done < <(installed_paths | grep -v 'icons/hicolor')
icons=("$PREFIX"/share/icons/hicolor/*/apps/aseprite.png)
printf '  ok      %s icon sizes\n' "${#icons[@]}"

[[ $missing -eq 0 ]] || { echo "error: install incomplete" >&2; exit 1; }

"$PREFIX/bin/aseprite" --version

case ":$PATH:" in
  *":$PREFIX/bin:"*) ;;
  *) echo; echo "note: $PREFIX/bin is not on your PATH -- the .desktop launcher needs it" ;;
esac

say "Done"
