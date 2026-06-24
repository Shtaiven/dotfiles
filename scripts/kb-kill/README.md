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
* No virtual device. kb-kill runs as a **hardened root system daemon** so that no
  ordinary user process needs access to your keyboards — see
  [Security model](#security-model).

## Requirements

* Python 3.11+ (for `tomllib`) and
  [`python-evdev`](https://python-evdev.readthedocs.io/)
  * Debian/Ubuntu/Pop!\_OS: `sudo apt install python3-evdev`
  * Arch: `sudo pacman -S python-evdev`
* `systemd` and `sudo` (the daemon is a root system service).
* The tray additionally needs PyGObject + `AyatanaAppIndicator3` — see
  [Tray icon](#tray-icon).

## Install

kb-kill is self-contained — run its installer (it uses `sudo` for the root parts):

```sh
./install.sh
```

This: symlinks `kb-kill`/`kb-kill-tray` into `~/.local/bin`; installs the default
config to `~/.config/kb-kill/kb-kill.toml` (asks before overwriting an existing
one); installs + enables the **tray** user service; copies the daemon to
`/usr/local/bin/kb-kill` (root-owned) and the hardened unit to
`/etc/systemd/system/kb-kill.service`; and enables the system service.

```sh
systemctl status kb-kill                 # the root daemon
journalctl -u kb-kill -f                 # watch KILLED / WOKEN live
```

Then, for the full security benefit, remove yourself from the `input` group so no
ordinary process can read keyboards (only the sandboxed daemon):

```sh
sudo gpasswd -d "$USER" input            # then log out and back in
```

Re-run `./install.sh` to redeploy after editing the daemon code (the daemon runs
from the root-owned copy, not your working tree).

To remove everything (binaries, units, icons; stops the services) while keeping
your config and the project files:

```sh
./uninstall.sh
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

The config is **hot-reloaded**: edit the file and the running service picks it up
within ~2 s (or send it `SIGHUP`). A group that is currently killed keeps that
state across the reload (so a reload never surprise-enables a disabled keyboard),
and if the new file fails to parse the error is logged and the previous config is
kept. The tray updates its menu automatically when groups change.

`virtual_keyboard` (default `false`): set `true` when the keyboard is fronted by
an input-remapper "forwarded" virtual device — kb-kill then targets that virtual
device and never the physical one. Leave it `false` for an ordinary keyboard,
which kb-kill grabs directly.

### Control socket (for the tray)

Two top-level keys gate the tray's control channel:

```toml
control_socket = true          # default false: no control socket / no inbound surface
control_user   = "your-name"   # who may command the daemon; default = config-file owner
```

`control_socket` must be `true` for the tray to show state and toggle groups. The
socket carries only group state — **never keystrokes** — and the daemon
authenticates each connection by the kernel-verified peer uid (`SO_PEERCRED`):
only `control_user` (or root) is accepted, others are dropped. See
[Security model](#security-model).

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
kb-kill                       # run the service (same as `kb-kill run`); systemd does this as root
sudo kb-kill detect           # list keyboards + which are targets + parsed combos
sudo kb-kill monitor          # print raw key events (debugging)
kb-kill -c PATH <cmd>         # use a specific config file
```

`detect` is the place to start. It needs `sudo` because reading input devices is
now restricted to root (you're no longer in the `input` group).

## Tray icon

`kb-kill-tray` is an optional tray icon (StatusNotifierItem) that shows whether
any group is **disabled** (⛔) or **active** (⌨) and lets you toggle a group by
clicking its menu entry. It is the **only** user-level piece: an unprivileged
**user** service that never sees keystrokes and just talks to the root daemon
over the control socket (`/run/kb-kill/control.sock`). The daemon itself is a
**root system service** (`systemctl … kb-kill`, no `--user`). Requires
`control_socket = true`.

```sh
systemctl --user enable --now kb-kill-tray   # tray only; install.sh already does this
```

* Works natively on **COSMIC** and **KDE Plasma**. On **GNOME** it needs the
  [AppIndicator extension](https://extensions.gnome.org/extension/615/appindicator-support/)
  (GNOME has no native tray).
* Requires PyGObject with `Gtk 3.0` and `AyatanaAppIndicator3`
  (`gir1.2-ayatanaappindicator3-0.1` on Debian/Pop, `libayatana-appindicator`
  on Arch).
* The icons live in `~/.config/kb-kill/icons/` and the menu lists every group
  from your config, so multiple groups each get their own toggle entry.

The control socket is also a small JSON line protocol if you want to script it:
send `{"cmd":"toggle","group":"<name>"}` (or `kill`/`wake`/`status`); the
service replies/broadcasts `{"type":"state","groups":[{"name","killed","targets"}]}`.

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

## Security model

kb-kill reads all keyboard input, so it is keylogger-*capable*. The design
minimizes and contains that:

* **No keystrokes are ever stored or transmitted.** The daemon keeps only the set
  of keys *currently held* (for combo matching) and discards them on key-up —
  there is no history, no log, no file, no network. The control socket carries
  only group state (`{name, killed, targets}`), never key data. (`kb-kill monitor`
  is a manual debug tool that prints to the terminal; the service never does.)
* **Runs as a hardened root daemon, so you can leave the `input` group.** That
  group is the real exposure — it lets *any* user process read every keyboard.
  With the root daemon you remove yourself from it
  (`sudo gpasswd -d "$USER" input`), so only the one audited, sandboxed process
  can read input.
* **The daemon binary is root-owned** (`/usr/local/bin/kb-kill`), never your
  user-writable working tree — a root service running a user-writable script
  would be a privilege-escalation hole. (Config may live in your home: it has no
  executable content.)
* **systemd sandbox** (`/etc/systemd/system/kb-kill.service`): no network
  (`RestrictAddressFamilies=AF_UNIX`, `IPAddressDeny=any`), only input devices
  (`DevicePolicy=closed` + `DeviceAllow=char-input`), all capabilities dropped,
  `SystemCallFilter`, `MemoryDenyWriteExecute`, `ProtectSystem=strict`, etc. — so
  even a hypothetical code-injection can't exfiltrate or touch other devices.
* **Control socket is optional and authenticated.** Off unless
  `control_socket = true`; the daemon checks the connecting peer's kernel-verified
  uid (`SO_PEERCRED`) and accepts only `control_user`/root; it bounds per-client
  buffering and connection count against DoS.

## Files

All in the self-contained project dir `scripts/kb-kill/`:

| Path | Purpose |
|---|---|
| `kb-kill` | the daemon (Python) — installed to `/usr/local/bin/kb-kill` (root) |
| `kb-kill-tray` | optional tray icon (Python / AppIndicator) — user process |
| `install.sh` | installer (user side + sudo root side) |
| `uninstall.sh` | reverses the install (keeps your config + project files) |
| `kb-kill.service` | hardened **system** unit → `/etc/systemd/system/` |
| `kb-kill-tray.service` | tray **user** unit → `~/.config/systemd/user/` |
| `kb-kill.toml` | example/default config |
| `icons/` | tray icons (awake / killed) |

Your personal config is kept in the dotfiles at
`stow/kb-kill/.config/kb-kill/kb-kill.toml` (stow → `~/.config/kb-kill/`).

## Troubleshooting

* **Nothing happens on the hotkey** — `sudo kb-kill detect`; confirm a target is
  found. If a key in your combo is remapped by input-remapper, use its remapped
  form.
* **A keyboard can't kill/wake itself** — restart the daemon after a code
  redeploy: `sudo systemctl restart kb-kill`.
* **Tray shows "connecting…"** — the daemon isn't running or `control_socket` is
  `false`; check `systemctl status kb-kill` and the config.
* **Stuck modifier after killing from the target** — shouldn't happen: kb-kill
  defers the grab until the target has no keys held. Report if it does.
