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

* bat (or batcat on debian/ubuntu, alternative for cat)
* carapace (shell completions)
* cargo (for rust package installation and dev)
* delta (sometimes called git-delta, alternative for diff)
* fd (sometimes called fd-find, alternative for find)
* firacode nerd font (a nerd font is required for many configs)
* fzf (fuzzy-find throughout your system)
* git
* nnn (cli file browser)
* nvim (text editor, alternative for vim)
* pixi (package manager)
* prezto (will be auto installed if zsh dots are installed)
* ripgrep (executable is rg, alternative for grep)
* starship (nice shell prompt)
* tmux (recommended to do a system install)
* wezterm (a terminal emulator to install locally)
* zoxide (executable is z, zi, alternative for cd)
* zsh (bash alternative with extra features)
