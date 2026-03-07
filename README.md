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
dots packages
```

to list available packages or

```sh
dots install shell bash
```
to install my bash config

## Recommended installs

* bat
* carapace
* cargo
* delta
* fd
* firacode nerd font (a nerd font is required for many configs)
* fzf
* git
* nnn
* nvim
* pixi
* prezto (will be auto installed)
* ripgrep
* starship
* tmux
* wezterm
* zoxide
* zsh

