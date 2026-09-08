# dots

Unified dotfiles management, wrapping [GNU Stow](https://www.gnu.org/software/stow/).

`dots` installs, removes, and inspects the packages under `stow/`, where each
package mirrors the layout of your home directory (`stow/zsh/.zshrc`,
`stow/nvim/.config/nvim/…`, etc.). Installing a package symlinks its files into
`~`; removing unlinks them without deleting the source.

## Install

`bootstrap.sh` symlinks `dots` into `~/.local/bin`, so it's on `PATH` after the
initial setup. Run `dots checkhealth` to confirm.

## Commands

| Command | What it does |
|---|---|
| `dots install <pkg>…` | Symlink a package's files into `~`, then apply its `.dots-install.toml`. On conflict, prompts to adopt / overwrite (with backup) / skip. `-y` accepts every post-install action, `--no-post` skips them. |
| `dots remove <pkg>…` | Remove the symlinks a package created (source files kept). |
| `dots list [--installed\|--not-installed\|--unmanaged]` | Show every package and its status: `installed`, `not installed`, or `partial`. |
| `dots adopt <pkg> <path>…` | Capture live files from `~` into a package, then re-stow them as symlinks. `--tracked` limits it to files git already tracks. |
| `dots update` | `git pull` the repo — only on `main` with a clean tree. |
| `dots dir [pkg]` | Print the absolute path to the repo root, or to `stow/<pkg>`. |
| `dots edit <pkg>` | Open `stow/<pkg>/` in `$EDITOR`. |
| `dots deploy <user@host>` | `scp` the repo to a remote host, optionally running `bootstrap.sh`. |
| `dots checkhealth` | Sanity-check the environment (stow installed, repo location, `dots` on PATH) plus every stowed package's declared dependencies. |
| `dots completion <bash\|zsh>` | Emit a shell completion script to stdout. |

Run `dots <command> --help` for full options and examples.

## Symlinks are always per-file (`--no-folding`)

`dots` runs stow with `--no-folding`, so installing creates real directories in
`~` and symlinks only the files inside them — never a link to a whole package
directory. Without it, stow "folds" a directory whose target doesn't exist yet
(`~/.config/nvim -> ~/.dotfiles/stow/nvim/.config/nvim`), which means any new
file the app writes there lands inside the repo, and untracked siblings can't
coexist with stowed ones.

Installing also unfolds directory symlinks left over from earlier installs, so
re-running `dots install <pkg>` migrates a folded package to per-file links.
Note that files living in the repo only because they were written through a
folded link are *not* symlinked back after unfolding — commit or delete them
first.

## Conflict handling (`install`)

When a target already exists with different content, `dots install` offers:

* **adopt** (`-a`) — move the existing file into the package and symlink it back
* **overwrite** (`-o`) — replace it with the package's version (timestamped backup saved)
* **copy** (`-c`) — copy real files instead of symlinking, for apps that save via
  atomic rename and would otherwise clobber stow symlinks (e.g. COSMIC)

## Adopting only tracked files (`adopt --tracked`)

By default `adopt` pulls in everything under the paths you give it, including
files the repo has never tracked. `-t` / `--tracked` restricts the copy to files
git already has in the index under `stow/<pkg>` — new and gitignored live files
are skipped, and directories that contain only untracked files aren't created.

It reads the index rather than the worktree, so it composes with the other
flags: `-o --tracked` wipes the package and restores just its tracked files from
the host, and it works with or without `--copy`. Combine with `--dry-run` to see
exactly what would be skipped.

```sh
dots adopt -c -t cosmic ~/.config/cosmic  # refresh only what's already tracked
```

## Post-install (`.dots-install.toml`)

A package declares what it needs in `stow/<pkg>/.dots-install.toml`, next to the
config it belongs to — no per-package branches inside `dots`. `dots install`
applies it after stowing, and `dots checkhealth` reports it.

`dots-install.toml` without the leading dot works identically; pick whichever
you prefer to see in `ls`. If a package somehow has both, the dotted one wins
and `dots` says which it ignored. Either name is invisible to stow
(`--ignore='^\.?dots-install\.toml$'`, anchored so a real dotfile like
`theme.dots-install.toml` still installs normally), and the copy-install, drift
and `adopt --overwrite` paths skip it too.

Every install is a `[y/N]` prompt that prints the exact command first. `-y` /
`--yes` accepts them all (useful on a fresh machine), `--no-post` skips the file
entirely.

```toml
description = "zsh + Prezto"          # shown as the checkhealth section title

[[program]]                            # something that must exist on the system
name = "fd"                            # required — display name
bin = ["fd", "fdfind"]                 # binaries to probe (default: [name])
pixi = "fd-find"                       # pixi global install <spec>
expose = ["fd"]                        # --expose names for that install
flatpak = "it.mijorus.smile"           # flatpak install <remote> <id>
flatpak_remote = "flathub"             # default "flathub"
apt = "wtype"                          # PRINTED, never run
dnf = "wtype"                          # PRINTED, never run
manual = "https://rustup.rs"           # printed instructions
note = "why the package needs it"
optional = true                        # checkhealth warns instead of erroring

[[git]]                                # a clone the config sources at runtime
name = "Prezto"
repo = "https://github.com/sorin-ionescu/prezto.git"
dest = "~/.zprezto"
check = "~/.zprezto/init.zsh"          # presence probe (default: dest)
recursive = true                       # clone --recursive

[[command]]                            # an installer to offer
name = "nnn plugins"
run = "curl -Ls .../getplugs | sh"     # runs via `sh -c`; $DOTFILES_DIR and
                                       # $STOW_DIR point at this repo
check = "~/.config/nnn/plugins/preview-tui"   # path that exists once done
check_cmd = "..."                      # ...or a command whose exit status is the probe
requires = ["curl"]                    # binaries needed to run it

[[service]]                            # a systemd unit the package ships
unit = "smile-autopaste.service"
scope = "user"                         # "user" (default) or "system"
enable = true                          # default true
restart = true                         # default true

[install]                              # how this package wants to be installed
copy = true                            # same as `dots install --copy`
overwrite = true                       # same as -o; on conflict, take the repo's version
adopt = true                           # same as -a; on conflict, absorb the live file
reason = "COSMIC rewrites its config by atomic rename"
```

Paths take `~` and `$VARS`, with `$XDG_CONFIG_HOME` and friends falling back to
their spec defaults when the host never exported them, and `$DOTFILES_DIR` /
`$STOW_DIR` always pointing at this repo — so a `[[command]]` can call an
installer kept in `scripts/installers/` instead of inlining a long pipeline. A malformed file, an
entry missing a required key,
or an unknown key is reported and skipped — a typo in a manifest never blocks a
package from being stowed.

### Declaring the install mode (`[install]`)

Some packages only work one way. COSMIC saves settings by atomic rename, which
replaces a stow symlink with a real file, so `stow/cosmic` declares:

```toml
[install]
copy = true
reason = "COSMIC saves settings by atomic rename, ..."
```

`dots install cosmic` then copies real files with no flag to remember, printing
the `reason` so it's clear why. The three modes are mutually exclusive — declare
two and both are ignored with a warning.

An explicit flag on the command line always wins, so a one-off
`dots install -a cosmic` still works and says what it overrode. `copy` applies
on every install; `overwrite` and `adopt` only engage when there's a conflict,
exactly as the flags do. There is deliberately no way to declare `-y`: whether
to install software without being asked stays your call, not a package's.

### What dots will and won't run

* **pixi, flatpak, git clones, `[[command]]` scripts** — offered with a prompt.
  The first usable installer for a program wins, so `pixi` takes precedence over
  `flatpak` when both are declared and pixi is on `PATH`.
* **`apt` / `dnf`, `manual`, `scope = "system"` services** — printed for you to
  run. These need `sudo` or vary per host, so `dots` never executes them.
* **systemd user units** — `daemon-reload` always runs, since the unit file was
  just relinked. A unit that isn't enabled yet prompts before
  `enable --now`; one that's already enabled is restarted with no prompt, which
  is the point of re-stowing its config. Set `restart = false` to leave it be.

`dots remove` is the inverse of stowing only — it unlinks files and does not
undo post-install steps, so a cloned repo stays cloned and an enabled unit stays
enabled. Disable those yourself if you mean to.

### Packages that ship one

| Package | Declares |
|---|---|
| `bat` | bat |
| `git` | git, delta |
| `nvim` | nvim |
| `shell` | bat, carapace, fd, fzf, nnn, ripgrep, zoxide, cargo (manual), nnn plugins |
| `smile` | Smile flatpak, wtype (apt/dnf), `smile-autopaste.service` |
| `starship` | starship |
| `tmux` | tmux, fzf |
| `wezterm` | wezterm (manual) |
| `logseq` | Logseq flatpak, the plugins pinned in `plugins.edn` |
| `zsh` | zsh, Prezto clone |
| `cosmic` | nothing to install — declares `[install] copy = true` |

## Examples

```sh
dots install zsh nvim shell     # install several packages
dots install -y zsh shell       # ...accepting every post-install action
dots list --not-installed       # what's not linked yet
dots adopt cosmic ~/.config/cosmic   # pull live changes back into the repo
dots adopt -c -t cosmic ~/.config/cosmic  # ...only the files already tracked
cd "$(dots dir nvim)"           # jump to a package directory
dots completion zsh >> ~/.zshrc # enable tab-completion
```
