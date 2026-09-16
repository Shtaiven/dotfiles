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
| `dots list [--installed\|--not-installed\|--unmanaged]` | Show every package and its status: `installed`, `not installed`, or `partial`. Copy-mode packages are reported as `copied`/`drifted` against the repo's contents. |
| `dots adopt <pkg> <path>…` | Capture live files from `~` into a package, then re-stow them as symlinks. `--tracked` limits it to files git already tracks. A package declaring `[install] copy = true` is adopted as copies instead; `--no-copy` opts out. |
| `dots update` | `git pull` the repo — only on `main` with a clean tree. |
| `dots dir [pkg]` | Print the absolute path to the repo root, or to `stow/<pkg>`. |
| `dots edit <pkg>` | Open `stow/<pkg>/` in `$EDITOR`. |
| `dots deploy <user@host>` | `scp` the repo to a remote host, optionally running `bootstrap.sh`. |
| `dots checkhealth` | Sanity-check the prerequisites (`dots` on PATH, stow, pixi) plus every installed package's declared dependencies. |
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

`--no-copy` is the opposite: it drops a `[install] copy = true` declared by the
package without naming a replacement, so the install symlinks and falls back to
the prompt above on conflict.

## Adopting only tracked files (`adopt --tracked`)

By default `adopt` pulls in everything under the paths you give it, including
files the repo has never tracked. `-t` / `--tracked` restricts the copy to files
git already has in the index under `stow/<pkg>` — new and gitignored live files
are skipped, and directories that contain only untracked files aren't created.

It reads the index rather than the worktree, so it composes with the other
flags: `-o --tracked` wipes the package and restores just its tracked files from
the host, and it works in either copy or symlink mode. Combine with `--dry-run`
to see exactly what would be skipped.

```sh
dots adopt -t cosmic ~/.config/cosmic  # refresh only what's already tracked
```

## Copy mode (`adopt --copy` / `--no-copy`)

`--copy` is the reverse of `dots install --copy`: live files are copied into the
package as real files and the re-stow step is skipped, because for a
copy-managed package the live files already *are* the installed copies.

You don't have to pass it. A package whose `.dots-install.toml` declares
`[install] copy = true` is adopted that way by default, in every mode —
plain, `--tracked`, `--overwrite`, `--dry-run` — so `adopt` and `install` treat
it the same way and neither needs a flag you have to remember. `dots` prints the
`reason` when it applies:

```
$ dots adopt cosmic ~/.config/cosmic
  cosmic: adopting with --copy per [install] copy = true — COSMIC saves settings by atomic rename, ...
```

`-c` / `--copy` is still there for a package that *doesn't* declare it — a
one-off copy adopt without editing the manifest. `--no-copy` is the opposite,
opting back out for one run: adopt the files and re-stow them as symlinks
anyway.

```sh
dots adopt -c logseq ~/.logseq            # copy mode for an undeclared package
dots adopt --no-copy cosmic ~/.config/cosmic  # symlink a copy-declared one
```

`-c` and `--no-copy` are mutually exclusive, and neither combines with `-i` /
`--install` — under copy mode there is nothing to re-stow.

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
check_path = "/usr/share/foo"          # a file that means it is present, for a
                                       # dependency that is not an executable
pixi = "fd-find"                       # pixi global install <spec>
expose = ["fd"]                        # narrow it to these commands; unset
                                       # (the default) exposes all of them
flatpak = "it.mijorus.smile"           # flatpak install <remote> <id>
flatpak_remote = "flathub"             # default "flathub"
apt = "wtype"                          # PRINTED, never run
dnf = "wtype"                          # PRINTED, never run
manual = "https://rustup.rs"           # printed instructions
note = "why the package needs it"
optional = true                        # checkhealth warns instead of erroring

A `[[program]]`'s probes are alternatives, not requirements — on `PATH`, or a
flatpak, or `check_path` existing, any one counts. `bash-completion` is the
case that needs it: `.bashrc` sources it from `/usr/share`, nothing ever
executes it, so `which` can never find it. (`[[command]]` reads its probes the
other way round: there they all have to agree.)

[[git]]                                # a clone the config sources at runtime
name = "Prezto"
repo = "https://github.com/sorin-ionescu/prezto.git"
dest = "~/.zprezto"
check_path = "~/.zprezto/init.zsh"     # presence probe (default: dest)
recursive = true                       # clone --recursive

[[command]]                            # an installer to offer
name = "nnn plugins"
run = "curl -Ls .../getplugs | sh"     # runs via `sh -c`; $DOTFILES_DIR and
                                       # $STOW_DIR point at this repo
check_path = "~/.config/nnn/..."       # a path that exists once it is done
check_cmd = "..."                      # a command that exits 0 once it is done
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
ignore = ["\\.md$", "^docs"]            # files that stay in the repo, never installed
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
the `reason` so it's clear why — and `dots adopt cosmic` copies in the other
direction for the same reason, unless you pass `--no-copy`. The three modes are mutually exclusive — declare
two and both are ignored with a warning.

A copy-mode package leaves no symlinks, so counting links says nothing about
it. Both status commands compare it against the repo's bytes instead:

```
cosmic (247 copied, 5 drifted)
```

`copied` is how many of the files the package owns are present in the target,
`drifted` how many of those differ from the repo, and `not copied` how many are
missing. Before this, every copied file counted as `unmanaged` — the label for
a *conflict* — so a correctly installed `cosmic` read as 247 problems and real
divergence was invisible inside that number. `--unmanaged` now selects copy
packages with drifted files, and `--installed` / `--not-installed` go by
whether the files are there.

`checkhealth` uses the same signal to decide whether to check a copy package's
dependencies, rather than reporting a perfectly installed `cosmic` as missing
and skipping them — and reports the drift itself, naming the files:

```
## cosmic — COSMIC desktop settings
  WARN  5 copied file(s) differ from the repo
          ~/.config/cosmic/com.system76.CosmicFiles/v1/tab
          ...
          dots adopt cosmic    # keep the live copies
          dots install cosmic  # restore the repo's
```

It names the first ten and counts the rest. A copy package with no drift says
so (`OK copied files all match the repo`), so silence never has to be read as
either "fine" or "not checked".

The comparison is byte-exact, so a file that differs only by a trailing newline
counts as drifted. `dots adopt cosmic` pulls the live version back into the
repo; `dots install cosmic` pushes the repo's version out.

An explicit flag on the command line always wins, so a one-off
`dots install -a cosmic` still works and says what it overrode; `--no-copy`
(on both `install` and `adopt`) drops a declared `copy` without picking another
mode. `copy` applies
on every install; `overwrite` and `adopt` only engage when there's a conflict,
exactly as the flags do. There is deliberately no way to declare `-y`: whether
to install software without being asked stays your call, not a package's.

### Keeping files out of `~` (`[install] ignore`)

Not everything in a package belongs in your home directory — notes, docs, an
upstream bundle's README. List regexes in `ignore` and those files stay in the
repo:

```toml
[install]
ignore = ["\\.md$", "^docs"]
```

They're passed to stow as `--ignore`, and `dots` applies the identical rules in
`dots list` and `dots install --copy`, so all three agree on what gets skipped.

Two things about the syntax, both inherited from stow:

* **Patterns are anchored at the end, not the start.** stow compiles each one as
  `($pattern)\z`, so `ignore = ["guide"]` does *not* match `guide.md` — use
  `guide.*` or `\.md$`. They match against the file's path within the package,
  so `^docs` and `\.md$` both work, and a pattern that matches a directory
  prunes everything under it.
* **Ignoring by extension still creates the parent directory.** `\.md$` leaves
  an empty `~/.config/app/docs/`, because stow creates the directory before
  finding nothing to link there. Ignore the directory instead (`^docs`, or
  `^\.config/app/docs`) and it's skipped entirely.

A package may end up ignoring *everything*. `stow/vscode` does: its whole
payload is a VS Code theme that has to be packed into a `.vsix` and installed
with `code --install-extension`, because VS Code no longer loads extension
folders that were merely dropped into `~/.vscode/extensions`. Nothing is
symlinked, a `[[command]]` does the work, and `dots list` says `vscode (0
stowed)` with no "not linked" count. `checkhealth` treats such a package as
present and checks its dependencies rather than reporting it as missing —
there is nothing it could ever install.

`dots` also mirrors stow's own built-in ignore list, so a package's top-level
`README.*`, `LICENSE.*` and `COPYING`, plus `.git*`, editor backups and VCS
directories at any depth, are skipped without being declared — and no longer
show up as permanently "not linked" in `dots list`. (If a package grows a
`.stow-local-ignore`, or you add `~/.stow-global-ignore`, stow uses that instead
of its built-in list; `dots` notices and stops applying the built-in rules
rather than reporting something stow wouldn't do.)

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
dots adopt -t cosmic ~/.config/cosmic  # ...only the files already tracked
cd "$(dots dir nvim)"           # jump to a package directory
dots completion zsh >> ~/.zshrc # enable tab-completion
```
