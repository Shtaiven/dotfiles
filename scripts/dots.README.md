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
| `dots install <pkg>…` | Symlink a package's files into `~`. On conflict, prompts to adopt / overwrite (with backup) / skip. |
| `dots remove <pkg>…` | Remove the symlinks a package created (source files kept). |
| `dots list [--installed\|--not-installed\|--unmanaged]` | Show every package and its status: `installed`, `not installed`, or `partial`. |
| `dots adopt <pkg> <path>…` | Capture live files from `~` into a package, then re-stow them as symlinks. |
| `dots update` | `git pull` the repo — only on `main` with a clean tree. |
| `dots dir [pkg]` | Print the absolute path to the repo root, or to `stow/<pkg>`. |
| `dots edit <pkg>` | Open `stow/<pkg>/` in `$EDITOR`. |
| `dots deploy <user@host>` | `scp` the repo to a remote host, optionally running `bootstrap.sh`. |
| `dots checkhealth` | Sanity-check the environment (stow installed, repo location, `dots` on PATH). |
| `dots completion <bash\|zsh>` | Emit a shell completion script to stdout. |

Run `dots <command> --help` for full options and examples.

## Conflict handling (`install`)

When a target already exists with different content, `dots install` offers:

* **adopt** (`-a`) — move the existing file into the package and symlink it back
* **overwrite** (`-o`) — replace it with the package's version (timestamped backup saved)
* **copy** (`-c`) — copy real files instead of symlinking, for apps that save via
  atomic rename and would otherwise clobber stow symlinks (e.g. COSMIC)

## Post-install hooks

Some packages run extra setup after stowing, in `post_install()`:

* `zsh` → offers to clone [Prezto](https://github.com/sorin-ionescu/prezto)
* `shell` → offers to install nnn plugins
* `kb-kill` → symlinks the `kb-kill` binary into `~/.local/bin` and offers to
  enable its systemd user service (see [kb-kill.README.md](./kb-kill.README.md))

## Examples

```sh
dots install zsh nvim shell     # install several packages
dots list --not-installed       # what's not linked yet
dots adopt cosmic ~/.config/cosmic   # pull live changes back into the repo
cd "$(dots dir nvim)"           # jump to a package directory
dots completion zsh >> ~/.zshrc # enable tab-completion
```
