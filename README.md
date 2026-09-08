# dotfiles

Personal dotfiles for unix-like systems.

## Installation

Clone this repository or copy its contents to your home folder as `~/.dotfiles`

```sh
git clone git@github.com:Shtaiven/dotfiles.git ~/.dotfiles
```

then bootstrap the installation

```sh
cd ~/.dotfiles
./bootstrap.sh
```

This will install pixi, stow, and curl for you if you don't already have them (you will be asked permission first)

The `dots` script will also become available for installing dotfiles. Try

```sh
dots list
```

to list available packages or

```sh
dots install shell bash
```
to install my bash config

## SSH Tools

The dotfiles come with some special commands for remote systems

```sh
dots deploy <user@host>  # deploy your locally installed dotfiles onto a system (you must still run dots install yourself)
ssht <user@host>  # copy over the local tmux config with TPM modules stripped and open tmux on the remote
distant-install <user@host>  # install distant.nvim on the remote which allows file editing remotely from nvim using your local config
```

## Recommended Programs

Each package declares the programs it needs in its own
`stow/<pkg>/.dots-install.toml`, so there's no list to keep in sync here.
`dots install <pkg>` offers to install them (via pixi or flatpak, prompting
first; apt/dnf commands are printed for you to run), and `dots checkhealth`
reports what's missing:

```sh
dots checkhealth              # what every stowed package still needs
dots install -y zsh shell     # install a package and accept its post-install steps
cat "$(dots dir shell)/.dots-install.toml"   # see what a package declares
```

The same file can declare how a package wants to be installed, so you don't have
to remember per-package flags — `stow/cosmic` sets `[install] copy = true`
because COSMIC would otherwise clobber a symlink, and `dots install cosmic`
just does the right thing.

See [scripts/dots.README.md](scripts/dots.README.md) for the file format
(`dots-install.toml` without the leading dot works too).

Two things aren't tied to a single package and `dots checkhealth` checks them
separately:

* **pixi** — the package manager `bootstrap.sh` installs, and the one most of
  the declared programs come from
* **a Nerd Font** (FiraCode Nerd Font is what these configs assume) — required
  by the prompt, editor and terminal configs; grab one from
  [nerdfonts.com](https://www.nerdfonts.com/font-downloads)
