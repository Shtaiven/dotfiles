# dotfiles

Personal dotfiles for *nix.

## Installation

1. Ensure dependencies are installed and on the path.

    ```zsh
    # install dependencies with your package manager, e.g.
    # Debian/Ubuntu
    sudo apt install zsh git stow curl fonts-firacode
    # Arch
    sudo pacman -S zsh git stow curl ttf-fira-code
    # Fedora
    sudo dnf install zsh git stow curl fira-code-fonts

    # install rustup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    # install starship
    sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y

    # install prezto
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "~/.zprezto"
    ```

1. Clone the dotfiles directory and `cd` into it.

    ```sh
    cd ~
    git clone git@github.com:Shtaiven/dotfiles.git .dotfiles
    cd ~/.dotfiles
    ```

1. For each package you want to install:

    ```sh
    stow -d stow -t $HOME -S <package>
    ```

    where `<package>` is the name of the package folder you would like to install, e.g. `stow -d stow -t $HOME -S zsh`.

    To install all packages, run:

    ```sh
    ./scripts/stow-all.sh
    ```

    The scripts `stow-all.sh` and `unstow-all.sh` are provided to perform this operation (and undo it).

## Recommended installs
    * ripgrep
    * fzf
    * bat
    * zoxide
    * tmux
    * exa
