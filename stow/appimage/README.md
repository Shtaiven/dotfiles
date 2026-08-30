# appimage

Make AppImages honour `QT_QPA_PLATFORMTHEME` by running them against the host's
Qt instead of their bundled copy.

## Why

Setting `QT_QPA_PLATFORMTHEME=cosmic` does nothing for a typical Qt AppImage,
for two stacked reasons. Checked against `openscad.appimage` (nightly
2026.08.28) on Fedora 44:

| | bundled in AppImage | on host |
| --- | --- | --- |
| Qt version | 6.2.4 | 6.11.1 |
| `plugins/platformthemes/` | *absent* | `libcutecosmictheme.so`, `libqt6ct.so`, `libqgtk3.so`, … |

The variable names a *plugin* Qt must `dlopen`, and the AppImage ships no
`platformthemes` directory at all — only `platforms/libqxcb.so`. Pointing
`QT_PLUGIN_PATH` at the host's plugins doesn't help either: Qt refuses to load a
plugin built against a **newer** Qt than the running process, and the host
plugin is built for 6.11.

So it is a version problem, not a configuration one. The fix is to stop the
bundled Qt from loading at all. Because the SONAMEs match
(`libQt6Core.so.6` either way), preloading the host libraries satisfies the
dependencies first and the bundled copies are never opened — even though
`AppRun` puts its own `usr/lib` first on `LD_LIBRARY_PATH`. AppImage binaries
are built against an older Qt 6 and Qt 6 is forward-compatible, so they run
fine on the newer host libraries.

Nothing inside the AppImage is modified, so updates keep working.

## Contents

| path | purpose |
| --- | --- |
| `.local/bin/appimage-host-qt` | Launch an AppImage against host Qt, or print the env vars to do so |

## Usage

Launch an AppImage through it:

```sh
appimage-host-qt ~/AppImages/openscad.appimage
```

Arguments after the AppImage path are passed through untouched.

### From a launcher

Point a desktop entry's `Exec=` at the wrapper:

```ini
Exec=/home/<you>/.local/bin/appimage-host-qt /home/<you>/AppImages/openscad.appimage %f
```

Desktop entries expand neither `~` nor `$HOME`, so both paths must be written
out in full. To generate the line with your own home substituted:

```sh
printf 'Exec=%s/.local/bin/appimage-host-qt %s/AppImages/openscad.appimage %%f\n' "$HOME" "$HOME"
```

### From a launcher that only accepts environment variables

Gear Lever exposes an environment-variable field but launches the AppImage
path directly, so the wrapper cannot sit in front of it. Generate the
equivalent vars and paste them in:

```sh
appimage-host-qt --print-env ~/AppImages/openscad.appimage | wl-copy
```

This emits `QT_PLUGIN_PATH=… LD_PRELOAD=…` on one line.

Note that Gear Lever rewrites its managed `.desktop` file on update and has
been observed dropping these vars. A launcher it does not manage (a separate
`*.desktop` using the `Exec=` form above) survives updates; add
`NoDisplay=true` to Gear Lever's own entry to avoid a duplicate in the app grid.

Gear Lever's *arguments* field cannot be used for any of this. It appends after
the AppImage path, so entries become arguments to the app itself; `Exec=` is
parsed into an argv vector and never passed to a shell, so `|`, `>`, `;` and
`$(…)` are inert there; and OpenSCAD rejects unknown options
(`unrecognised option '-style'`) before Qt parses argv.

## How the preload list is built

The list is the intersection of the libraries the AppImage bundles
(`usr/lib/*.so*`) and those the host provides in `/usr/lib64` — so only
libraries that would actually have collided are preloaded, not all 100+ of the
host's Qt modules.

It is cached under `${XDG_CACHE_HOME:-~/.cache}/appimage-host-qt/`, keyed by the
AppImage's size and mtime, and recomputed automatically when the AppImage
changes. New Qt modules in a later release and host SONAME bumps are picked up
without editing anything. Building the list costs ~0.5s once per version; cached
runs add no measurable startup time.

| variable | default | effect |
| --- | --- | --- |
| `APPIMAGE_HOST_LIBDIR` | `/usr/lib64` | Where to find the host libraries |

## Troubleshooting

If an app stops picking up the theme after an update, run it from a terminal and
read stderr. A `version … not found` or `undefined symbol` line names a library
that needs to resolve to the host copy; the intersection normally handles this,
but a library the host lacks entirely will show up here.

To confirm the host Qt is actually in use, check that no bundled Qt libraries
are mapped and the theme plugin is:

```sh
grep -c 'usr/lib/libQt6' /proc/<pid>/maps          # expect 0
grep -o 'platformthemes/.*\.so' /proc/<pid>/maps   # expect the host plugin
```

## Limits

Only helps AppImages that bundle Qt **6**. A bundled Qt 5 app needs the Qt 5
host libraries and `/usr/lib64/qt5/plugins` instead, and a future host Qt 7
would not be loadable by a Qt 6 application at all.
