# Pixi completions
if command -v pixi >/dev/null 2>&1; then
	if [ -n "$ZSH_VERSION" ]; then
		eval "$(pixi completion --shell zsh)"
	elif [ -n "$BASH_VERSION" ]; then
		eval "$(pixi completion --shell bash)"
	fi
fi
