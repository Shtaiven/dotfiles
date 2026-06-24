# scripts

Standalone scripts and helpers for these dotfiles. The main user-facing tools
have their own READMEs:

| Tool | Description | Docs |
|---|---|---|
| `dots` | Dotfiles management wrapping GNU Stow (install / remove / adopt / …) | [dots.README.md](./dots.README.md) |
| `kb-kill/` | Disable/enable a target keyboard with a global hotkey (self-contained sub-project, slated to move to its own repo) | [kb-kill/README.md](./kb-kill/README.md) |
| `term-colors` | Print the terminal's ANSI color palette as blocks | [term-colors.README.md](./term-colors.README.md) |

## pre-commit hooks

Small checks wired into `.pre-commit-config.yaml`:

| Script | Purpose |
|---|---|
| `check-dotfiles-sentinel.sh` | Verify the dotfiles sentinel is the last line of each file — catches installer blocks (nvm, conda, …) appended to shell rc files |
| `check-hardcoded-home.sh` | Fail if a file hardcodes `/home/username` instead of `$HOME` |
| `zsh-syntax-check.sh` | Run `zsh -n` (syntax-only) on staged zsh files |

## Subdirectories

* **`gnome/`** — GNOME helpers: `gnome-extension-backup.sh`,
  `gnome-extension-load.sh`, `gnome-restart.sh`.
* **`installers/`** — one-off installers for tools that aren't packaged via stow
  (`nvim.sh`, `kitty.sh`, `wezterm.sh`, `zellij.sh`, webi packages, `update.sh`).
