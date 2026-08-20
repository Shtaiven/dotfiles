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
| `.local/bin/smile-autopaste` | types the emoji via `wtype` on Smile's `CopiedEmojiBroadcast` signal |
| `.config/autostart/smile-hidden.desktop` | start Smile hidden at login so it stays resident |
| `.config/systemd/user/smile-autopaste.service` | supervise `smile-autopaste` |

## Autopaste

Smile cannot synthesise input on Wayland -- `Picker.py` calls xdotool only in an
`XDG_SESSION_TYPE != wayland` branch -- so it emits `CopiedEmojiBroadcast` and
stops. `smile-autopaste` listens for that and delivers the emoji itself.

**Backend is wtype**, which types the emoji carried in the signal payload. It
uploads a generated keymap over `zwp_virtual_keyboard_v1`, which cosmic-comp
implements. Verified end to end through the service: `🎉👍🏻👨‍👩‍👧` arrived intact
(skin-tone modifier and ZWJ sequence included) with the clipboard holding
unrelated text throughout, and `🎉` arrived in a **terminal**, which the old
ctrl+v backend could never do -- ctrl+v is not paste there, ctrl+shift+v is.

**Delivery must wait for focus.** `default_hiding_action()` calls
`set_visible(False)` and emits the signal in the same breath, so at that instant
cosmic-comp has not handed keyboard focus back to the window you were in, and
input synthesised immediately goes to a surface that is going away. `SETTLE`
covers that handover. It was first proven at 0.25s on the ctrl+v backend --
journal showed signal at `11:28:53.074`, keystroke at `11:28:53.328`, paste
landed -- and is set to 0.1s now. 0.1s is not measured against the handover;
if an emoji ever fails to appear, raise it before suspecting anything else. This is about input
routing, not the backend -- the compositor delivers to whatever surface holds
focus, so wtype needs the wait exactly as much as ctrl+v did. Without it every
link checks out (emoji copied, broadcast on the bus, backend alive) and nothing
appears, which makes it the confusing failure.

### Why not dotool

dotool was the original backend and is no longer used. Two findings from it, kept
so they are not rediscovered:

`dotool` cannot type emoji. It maps characters onto keys of the active XKB layout,
and emoji are in no layout:

```
dotool: WARNING: impossible character for layout: 🎉
```

`DOTOOL_XKB_LAYOUT`/`DOTOOL_XKB_VARIANT` cannot help -- they only select a
different layout. Verified in a focused window: `type CONTROL-OK` arrives,
`type 🎉` produces nothing. That left only replaying ctrl+v, which depends on the
clipboard and does nothing at all in a terminal.

And ctrl+v had to go through `dotoolc`, not `dotool`: a one-shot `dotool` creates
a uinput device, writes, and exits before cosmic-comp binds the device. Measured
with a reversible `key volumeup`:

| how the keystroke is sent | result |
| --- | --- |
| `echo 'key volumeup' \| dotool` | 3 of 3 lost |
| `echo 'key volumeup' \| dotoolc`, dotoold running | lands every time |

That needed a `dotoold.service` holding a uinput device open for the whole
session. wtype needs no daemon, so that unit is gone.

### Portability

wtype is the less portable choice, worth knowing if this package is ever reused:

| session | wtype |
| --- | --- |
| COSMIC, sway, Hyprland (wlroots) | works |
| KDE Plasma Wayland | works, KWin implements the protocol |
| GNOME Wayland | does not work, Mutter does not implement virtual-keyboard-unstable-v1 |
| GNOME/KDE on X11 | not needed, Smile calls xdotool itself |

GNOME is out of scope for this package. If it ever matters: the Smile
Complementary Extension pastes inside the shell there, and Smile then emits
`CopiedEmoji` rather than `CopiedEmojiBroadcast`, which this script does not
listen for -- so GNOME needs the extension, not this.

## Install

```sh
dots install smile   # choose [o]verwrite for smile-autopaste.service
systemctl --user daemon-reload
systemctl --user enable --now smile-autopaste.service
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

* `wtype` (`apt install wtype`), and a compositor implementing
  `zwp_virtual_keyboard_v1` -- see Portability
* the `it.mijorus.smile` Flatpak: `flatpak install flathub it.mijorus.smile`
