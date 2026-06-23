# kb-kill

Disable/enable a target keyboard with a global hotkey, as a background service.

Press the **kill** hotkey on *any* keyboard to disable a target keyboard (e.g.
the laptop's built-in keyboard). While disabled, every key from the target is
swallowed **except** the **wake** hotkey — so the target keyboard can always
wake itself. There is no way to lock yourself out.

Typical use: you're docked with an external keyboard and want the laptop's
built-in keyboard to stop registering stray presses.

## How it works

* "Disable" means an exclusive `EVIOCGRAB` on the target device: the kernel
  routes its events only to kb-kill, which drops them.
* The grab happens **only while killed**. When awake, kb-kill merely *monitors*
  keyboards (reads, never grabs, never re-injects), so normal typing is 100%
  native and a crash of the service cannot break your keyboard. The kernel also
  releases every grab automatically if the process dies.
* Hotkeys are matched **globally** (across the union of all keyboards), not
  per-device — see [input-remapper](#input-remapper-coexistence) for why that
  matters.
* No virtual device, no root: membership of the `input` group is enough.

## Requirements

* Python 3 and [`python-evdev`](https://python-evdev.readthedocs.io/)
  * Debian/Ubuntu/Pop!\_OS: `sudo apt install python3-evdev`
  * Arch: `sudo pacman -S python-evdev`
* Your user in the `input` group: `sudo usermod -aG input $USER` (then re-login)

## Install

Managed through `dots` (GNU stow + a post-install hook):

```sh
dots install kb-kill
```

This stows the config and the systemd user unit, symlinks `kb-kill` into
`~/.local/bin`, and offers to enable the service. Then:

```sh
systemctl --user enable --now kb-kill   # if you skipped it during install
systemctl --user status kb-kill
journalctl --user -u kb-kill -f         # watch KILLED / WOKEN live
```

## Configuration

Config is [TOML](https://toml.io), read from the first of: `--config PATH`,
`$KB_KILL_CONFIG`, `~/.config/kb-kill/kb-kill.toml`, `~/.kb-kill`,
`/etc/kb-kill/kb-kill.toml`.

A simple single-keyboard config:

```toml
keyboards  = "AT Translated Set 2 keyboard"
kill_combo = "ctrl+alt+shift+k"
wake_combo = "ctrl+alt+shift+u"   # always honored on the killed keyboard
virtual_keyboard = true           # input-remapper-managed; see coexistence below
```

`keyboards` is a string or a list of strings — case-insensitive substrings
matched against device names (`kb-kill detect` shows the names). Use
`keyboards = "*"` to match **every** keyboard.

`virtual_keyboard` (default `false`): set `true` when the keyboard is fronted by
an input-remapper "forwarded" virtual device — kb-kill then targets that virtual
device and never the physical one. Leave it `false` for an ordinary keyboard,
which kb-kill grabs directly.

### Groups: per-keyboard hotkeys

You can define several independent **groups**, each with its own target
keyboards and its own kill/wake hotkeys:

* The **top-level** keys (above) are the **default group** (when they include
  `keyboards`) and also supply **defaults** that every `[groups.*]` inherits.
* Each **`[groups.<name>]`** table adds a group; it inherits `kill_combo` and
  `wake_combo` unless it sets its own. `virtual_keyboard` is per-group (default
  `false`) and is **not** inherited.
* TOML rule: top-level keys must come **before** any `[groups.*]` table.
* Give each group a **distinct** combo — a shared combo simply kills both.

```toml
wake_combo = "ctrl+alt+shift+u"               # default, inherited below

keyboards  = "AT Translated Set 2 keyboard"   # default group (the laptop)
kill_combo = "ctrl+alt+shift+k"
virtual_keyboard = true                       # input-remapper-managed

[groups.externals]
keyboards  = ["KBDfans", "solaar-keyboard"]
kill_combo = "ctrl+alt+shift+j"
wake_combo = "ctrl+alt+shift+m"               # overrides the default
# virtual_keyboard defaults to false → grabbed directly
```

Any keyboard can trigger any group's hotkey, and each group kills/wakes
independently. Groups should target **disjoint** keyboards; if they overlap, a
device stays disabled while *any* group targeting it is killed.

### Hotkey syntax

Tokens joined by `+`. Each token is an "any-of" group; the combo fires when
every group has at least one key held.

| token | matches |
|---|---|
| `ctrl` / `control` | either Ctrl |
| `lctrl` / `rctrl` | left / right Ctrl only |
| `alt` | either Alt (`ralt` = AltGr) |
| `shift` | either Shift |
| `super` / `meta` / `win` / `cmd` | either Super |
| `lalt`/`ralt`, `lshift`/`rshift`, `lsuper`/`rsuper` | pin a side |
| `a`–`z`, a raw `KEY_*` name, or a numeric code | that single key |

## Commands

```sh
kb-kill                  # run the service (same as `kb-kill run`)
kb-kill detect           # list keyboards, show which are targets + parsed combos
kb-kill monitor          # print raw key events (debugging) - shows device + keycode
kb-kill -c PATH <cmd>    # use a specific config file
```

`detect` is the place to start: it shows each keyboard's name, whether it's a
target, and flags permission/input-group problems.

## input-remapper coexistence

kb-kill is built to run alongside [input-remapper](https://github.com/sezanzeb/input-remapper).

When input-remapper manages a keyboard it grabs the **physical** device (e.g.
`/dev/input/event3`) and re-emits its events through **virtual** devices:

* a per-keyboard `…forwarded` device for **un-remapped** (passthrough) keys, and
* the shared `input-remapper keyboard` device for the **output of mappings**.

Mark such a group **`virtual_keyboard = true`** and kb-kill targets the
**forwarded** (virtual) device and **never the physical one**, so input-remapper
can always (re)grab the physical keyboard — including across an input-remapper
restart (kb-kill re-attaches by name). If the forwarded device isn't present
(input-remapper not running), a `virtual_keyboard` group simply grabs nothing
rather than risk fighting input-remapper for the physical device.

Two consequences worth knowing:

1. **Combos are matched globally**, because a single physical keyboard's keys
   can be split across two virtual devices (a remapped modifier on
   `input-remapper keyboard`, the rest on the `…forwarded` device). Per-device
   matching would never see the whole combo.
2. **Remapped keys are not eaten while killed.** kb-kill grabs only the
   forwarded device, not input-remapper's *shared* output device (grabbing that
   would also suppress remapped output from every other device — e.g. mice doing
   workspace switching). So while killed, ordinary typing is eaten but anything
   input-remapper *remaps* still passes through. Use the hotkey's modifiers as
   they exist **after** remapping (e.g. if CapsLock is mapped to Ctrl, press
   CapsLock for the `ctrl` token).

For a keyboard that input-remapper doesn't manage, leave `virtual_keyboard`
at its default (`false`) and kb-kill grabs the physical keyboard directly.

## Files

| Path | Purpose |
|---|---|
| `scripts/kb-kill` | the service (Python) |
| `stow/kb-kill/.config/kb-kill/kb-kill.toml` | default config |
| `stow/kb-kill/.config/systemd/user/kb-kill.service` | systemd user unit |
| `scripts/dots` | `post_install` hook that symlinks the binary + enables the service |

## Troubleshooting

* **Nothing happens on the hotkey** — run `kb-kill detect`; confirm a target is
  found and you're in the `input` group. If a key in your combo is remapped by
  input-remapper, use its remapped form.
* **A keyboard can't kill/wake itself** — make sure you're on the current
  version (global combo matching); restart the service after updating:
  `systemctl --user restart kb-kill`.
* **Stuck modifier after killing from the target** — shouldn't happen: kb-kill
  defers the grab until the target has no keys held. Report if it does.
