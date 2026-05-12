# shellcheck shell=bash
# Shared sr work config — sourced by both bash (.bashrc) and zsh (.zshrc).

# Ensure pixi bin is on PATH (may not be set in non-login shells)
[[ -d "$HOME/.pixi/bin" && ":$PATH:" != *":$HOME/.pixi/bin:"* ]] && export PATH="$HOME/.pixi/bin:$PATH"

export SR_DOTS_DIR="$HOME/dots"
export SR_INSTALLATION_TOOLS_DIR="$HOME/src/sr_installation_tools"

# Source bash-only sr helper files.
# Caveats handled:
#  - `cd` is aliased to `z` (zoxide) by .shell.d/aliases.sh, which breaks
#    setup.bash's `$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )` line.
#    Disable alias expansion during the source.
#  - In zsh, BASH_SOURCE isn't populated by `emulate bash`, so fake it.
if [[ -n "$ZSH_VERSION" ]]; then
	_sr_source_bash() {
		emulate -L bash
		setopt no_aliases
		typeset -ga BASH_SOURCE
		BASH_SOURCE=("$1")
		source "$1"
	}
elif [[ -n "$BASH_VERSION" ]]; then
	_sr_source_bash() {
		local _restore_expand=0
		shopt -q expand_aliases && _restore_expand=1
		shopt -u expand_aliases
		source "$1"
		(( _restore_expand )) && shopt -s expand_aliases
	}
fi
[[ -f "$SR_DOTS_DIR/setup.bash" ]] && _sr_source_bash "$SR_DOTS_DIR/setup.bash"
[[ -f "$HOME/src/sr_deployment/scripts/common.bash" ]] && _sr_source_bash "$HOME/src/sr_deployment/scripts/common.bash"
unset -f _sr_source_bash
[[ -n "$ZSH_VERSION" ]] && unset BASH_SOURCE

alias sr-update="( cd $SR_DOTS_DIR && git pull );pixi global install --force-reinstall caty sr_installation_tools -c https://conda.smart-robotics.nl/get/smart-robotics -c conda-forge"

alias sr-clion='tmux new -d sr run clion \$CONDA_DEFAULT_ENV'
alias sr-code='tmux new -d sr run code \$CONDA_DEFAULT_ENV'
alias sr-pycharm='tmux new -d sr run pycharm \$CONDA_DEFAULT_ENV'

function yes_or_no {
    if [[ -n "$SKIP_ASK" ]] ; then return 0; fi
    while true; do
        echo -e "$* [y/n]: "
        read -r yn
        case $yn in
            [Yy]*) return 0  ;;
            [Nn]*) echo "No" ; return  1 ;;
        esac
    done
}

publish-rn-link ()
{
    local TAG;
    local FILE;
    local remote;
    local text;
    TAG=$(git describe --exact-match --tags);
    FILE=$(git show --name-only HEAD~ | tail -n1);
    commit=0
    while ! yes_or_no "Is ${FILE} the changelog"; do
        FILE=$(git show --name-only HEAD~${commit} | tail -n1);
        commit=$((commit + 1))
    done
    remote=$(git remote get-url origin);
    remote=${remote/git@git.smart-robotics.nl:/https:\/\/git.smart-robotics.nl\/};
    remote=${remote%.git};

    text="<${remote}/-/blob/${TAG}/${FILE} | ${remote##*/}@${TAG}>"
    if [[ -n "$1" ]] ; then
       text="${text} ($1)"
    fi
    text="${text} by $(git config user.name)"
    if yes_or_no "Post ${text} to #release_tags?"
        then
          curl -X POST -H 'Content-type: application/json' --data "{'text' : '${text}'  } " "$SR_SLACK_WEBHOOK_URL"
    fi
}
