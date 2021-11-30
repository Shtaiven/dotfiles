# dotfiles

Personal dotfiles for *nix

## Installation

1. Ensure dependencies are installed and on the path.

    ```zsh
    # install dependencies with your package manager, e.g.
    sudo apt install zsh git stow curl
    # or
    sudo pacman -S zsh git stow curl

    # install rustup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    # install starship
    sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y

    # install prezto
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "~/.zprezto"
    ```

1. Clone the dotfiles directory and `cd` into it.

    ```zsh
    cd ~
    git clone git@github.com:Shtaiven/dotfiles.git .dotfiles
    cd ~/.dotfiles
    ```

1. For each package you want to install:

    ```zsh
    stow <package>
    ```

    where `<package>` is the name of the package folder you would like to install, e.g. `stow zsh`. To install all packages, run:

    ```zsh
    for f in */ ; do
        if [ -d "$f" ]; then
            stow ${f%*/}
        fi
    done
    ```
