# git-share

Print `git clone` commands that recreate the repos in the current directory,
each on what it has checked out — for handing a workspace layout to someone
else. `git share` runs it (any `git-*` executable on `PATH` is a git
subcommand). POSIX `sh`, needs only git and sed.

```
$ git share
git clone git@host:group/foo.git --branch main foo
git clone git@host:group/bar.git --branch v1.4.0 bar
git clone git@host:group/baz.git baz && git -C baz checkout 9bf732a1a078…
warning: foo/: 1 commit(s) on main not pushed to origin/main
warning: qux/: not a git repo
```

The clone lines go to stdout and the warnings to stderr, so
`git share > clone.sh` captures only the commands.

## Install

`dots install git` symlinks it to `~/.local/bin/git-share` and writes its man
page to `~/.local/share/man/man1/git-share.1`, so `git share --help` works (git
turns `--help` into `man git-share`). Both are a `[[command]]` in
`stow/git/.dots-install.toml`.

### Without these dotfiles

It's a single file that needs only `sh` and `git` plus standard tools, so
anyone can install it:

```sh
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/Shtaiven/dotfiles/main/scripts/git-share -o ~/.local/bin/git-share
chmod +x ~/.local/bin/git-share
mkdir -p ~/.local/share/man/man1   # optional: makes `git share --help` work
~/.local/bin/git-share --man > ~/.local/share/man/man1/git-share.1
```

`~/.local/bin` has to be on `PATH` (it is by default on most Linux distros).
Git runs any `git-*` program on `PATH` as a subcommand, so no alias is needed
for `git share`. To pin a version, replace `main` in the URL with a commit
hash.

## Usage

```sh
git share              # every subdirectory of .
git share foo bar      # just these
git share -r upstream  # clone from this remote instead
git share -g           # no warnings about folders that aren't git repos
git share -q           # no warnings at all
```

## What it picks

- **Remote:** the checked-out branch's upstream remote, else `origin`, else
  the repo's only remote. `-r` overrides.
- **What to check out:** the checked-out branch, by its name *on the remote*
  (a local `mine` tracking `origin/feature-x` becomes `--branch feature-x`).
  If the branch isn't on the remote, or nothing is checked out, an exact tag
  is used, and failing that the full commit hash, with `git -C dir checkout`
  since `--branch` can't take a commit.
- **Folder:** each clone goes into the same folder name, so the layout matches
  even when it differs from the repo name. Names and URLs are shell-quoted when
  needed.

## Warnings

Listed at the end (in yellow on a terminal, unless `NO_COLOR` is set or
`color.ui` is off), for what the clones won't reproduce:

- commits on the branch not pushed to the remote
- a branch that isn't on the remote
- a checked-out commit that isn't on any remote branch (that clone will fail)
- uncommitted changes

and for folders that were skipped: not a git repo (including plain folders
inside a parent repo), bare repos, symlinks, repos with no remote (or several
and no `origin`; pick one with `-r`), and repos with no commits.

Tags can't be checked for being pushed without asking the server, so a
local-only tag isn't warned about.
