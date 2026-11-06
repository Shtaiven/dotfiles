# git-dirs

Show the git state of every subdirectory, one aligned row each — for a folder
full of checkouts. `git ls`, `git ll` and `git dirs` all run it (git picks up
any `git-*` executable on `PATH` as a subcommand). POSIX `sh`, needs only git
and awk.

```
behind/      main        95985ec  ↑1 ↓2
dirty/       main        d24ebe3  local  +1 ~1 ?2
gone/        feat        d24ebe3  gone
detached/    HEAD        d24ebe3
tagged/      tag:v1.4.0  d24ebe3
rebasing/    side        4c080f8         !1  REBASE
plain/       -  not a git repo
remote.git/  -  bare repo
```

## Install

`dots install shell` symlinks it to `~/.local/bin/git-dirs` (a `[[command]]` in
`stow/shell/.dots-install.toml`).

## Usage

```sh
git ls                 # . itself (as ./), then every subdirectory
git ls -a              # include hidden directories
git ls foo bar         # just these
git ls --color=always | less -R
```

## Columns

| Column | Shows |
|---|---|
| name | the directory |
| ref | branch; `tag:NAME` when detached on a tag; `HEAD` when detached on a plain commit; the branch being rebased during a rebase |
| commit | short hash of `HEAD`, `(empty)` before the first commit |
| sync | `↑N` ahead / `↓N` behind upstream, blank when in sync or detached, `local` = no upstream, `gone` = upstream deleted |
| state | blank when clean; `+N` staged, `~N` modified, `?N` untracked, `!N` conflicts, then `REBASE` / `MERGE` / `CHERRY-PICK` / `REVERT` / `BISECT` if one is in progress |

Folders that aren't repos are grayed out, name included: `not a git repo`, or
`in parent repo` (a plain folder tracked by the enclosing repo — it no longer
shows the parent's branch). Bare repos keep their directory color, with a gray
`bare repo` note.

## Colors

Each color comes from the place that already defines it, so your existing
settings apply:

| Element | Source | Default |
|---|---|---|
| directory name | `di` (`ln` for symlinks) in `$LS_COLORS` | `01;34` |
| branch | `color.status.localBranch` | green |
| `tag:NAME` | `color.decorate.tag` | bold yellow |
| detached `HEAD` | `color.status.nobranch` | red |
| commit | `color.diff.commit` | yellow |
| `gone` | `color.status.remoteBranch` | red |
| `+N` / `~N` / `?N` / `!N` | `color.status.added` / `changed` / `untracked` / `unmerged` | green / red / red / red |
| non-repo rows | ANSI `90` | gray |
| `local` | ANSI `2` | dim |
| `REBASE` etc. | ANSI `1;35` | bold magenta |

The ahead/behind arrows are uncolored. Color is used on a TTY unless
`NO_COLOR` is set or `color.ui` is off; `--color=always|never` overrides.

Repos are probed in parallel (2× CPU count at a time).
