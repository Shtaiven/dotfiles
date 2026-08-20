# smile

Low-latency setup for [Smile](https://smile.mijorus.it) (`it.mijorus.smile`), the
Flatpak emoji picker, on cosmic-epoch / Wayland.

## Why

The obvious keybinding, `Spawn("flatpak run it.mijorus.smile")`, is slow even
when Smile is already running. Measured on a resident instance:

| how the picker is activated | time |
| --- | --- |
| `flatpak run it.mijorus.smile` | 0.50s, occasional 2.8s spikes |
| `org.gtk.Application.Activate` over D-Bus | 0.005s |

`flatpak run` spends that half-second constructing a throwaway `bwrap` +
`xdg-dbus-proxy` sandbox whose only job is to hand a GApplication activation to
the instance that is already running, then exit. `smile-toggle` sends that
activation itself and only falls back to `flatpak run` when Smile is not
running (it is not `DBusActivatable`, so D-Bus cannot start it on demand).

Cold start is ~1.0-1.4s to UI-ready, so `smile-hidden.desktop` starts Smile
hidden at login and the first keypress of the session doesn't pay for it either.

Measured after wiring it up: 0.006s warm, 1.4s on the cold fallback.

## Contents

| path | purpose |
| --- | --- |
| `.local/bin/smile-toggle` | activate Smile over D-Bus, fall back to `flatpak run` |
| `.local/bin/smile-autopaste` | presses ctrl+v via `dotoolc` on Smile's `CopiedEmojiBroadcast` signal |
| `.config/autostart/smile-hidden.desktop` | start Smile hidden at login so it stays resident |
| `.config/systemd/user/smile-autopaste.service` | supervise `smile-autopaste` |
| `.config/systemd/user/dotoold.service` | keep one uinput device open for the session |

## Autopaste

Smile cannot synthesise input on Wayland -- `Picker.py` calls xdotool only in an
`XDG_SESSION_TYPE != wayland` branch -- so it emits `CopiedEmojiBroadcast` and
stops. `smile-autopaste` listens for that and replays ctrl+v.

Two things about this that are not obvious:

**It must go through `dotoolc`, not `dotool`.** A one-shot `dotool` creates a
uinput device, writes, and exits before cosmic-comp binds the device, so the
keystroke is silently dropped. Measured with a reversible `key volumeup`:

| how the keystroke is sent | result |
| --- | --- |
| `echo 'key ctrl+v' \| dotool` | 3 of 3 lost |
| `echo 'key ctrl+v' \| dotoolc`, dotoold running | lands every time |

That is why `dotoold.service` exists and `smile-autopaste.service` has
`Requires=dotoold.service`.

**Typing the emoji instead of pasting it does not work with dotool.** The signal
payload carries the text, so `type <emoji>` looks like the cleaner design -- no
clipboard, and it would fix ctrl+v not being paste in a terminal. But dotool maps
characters onto keys of the active XKB layout and emoji are in no layout:

```
dotool: WARNING: impossible character for layout: 🎉
```

`DOTOOL_XKB_LAYOUT`/`DOTOOL_XKB_VARIANT` cannot help. Verified in a focused
window: `type CONTROL-OK` arrives, `type 🎉` produces nothing.

`wtype` would work -- it uploads a generated keymap over
`zwp_virtual_keyboard_v1`, which cosmic-comp implements (the interface is in the
`cosmic-comp` binary) -- and is packaged as `wtype 0.4-3`. Switching to it would
drop the clipboard dependency and make autopaste work in terminals too.

## Known limitation

ctrl+v is not paste in a terminal (that is ctrl+shift+v), so autopaste does
nothing when a terminal has focus. Only a typing-based backend fixes that.

## Install

```sh
dots install smile   # choose [o]verwrite for smile-autopaste.service
systemctl --user daemon-reload
systemctl --user enable --now dotoold.service smile-autopaste.service
```

`~/.config/systemd/user/smile-autopaste.service` already exists as a real file
and will conflict. Overwrite rather than adopt: the version here runs
`%h/.local/bin/smile-autopaste` instead of the old hardcoded
`/home/$USER/.local/share/it.mijorus.smile/smile-autopaste.sh`. Delete that
stale script afterwards.

The keyboard shortcut lives in the `cosmic` package, as
`Spawn("$HOME/.local/bin/smile-toggle")` on Super+E — an absolute path because
cosmic-comp runs `Spawn` through `sh -c` with the session's PATH, which may not
include `~/.local/bin`. Set it by hand in Settings → Keyboard → Shortcuts if
you are not stowing `cosmic`.

Smile's own settings are dconf, not files, so they cannot be stowed. Residency
depends on them:

```sh
flatpak run --command=gsettings it.mijorus.smile set it.mijorus.smile load-hidden-on-startup true
flatpak run --command=gsettings it.mijorus.smile set it.mijorus.smile iconify-on-esc false
flatpak run --command=gsettings it.mijorus.smile set it.mijorus.smile auto-paste true
```

With `load-hidden-on-startup=true` and `iconify-on-esc=false`, Smile's
`default_hiding_action()` calls `set_visible(False)` rather than `close()`, so
the process survives picking an emoji and later activations stay on the 5ms path.

## Requires

* `dotool`, `dotoold` and `dotoolc` on PATH (https://sr.ht/~geb/dotool/)
* write access to `/dev/uinput`. `/etc/udev/rules.d/80-dotool.rules` grants it
  per-login via an ACL (`getfacl /dev/uinput` should list you), so membership of
  the `input` group is not required
* the `it.mijorus.smile` Flatpak: `flatpak install flathub it.mijorus.smile`
