##
# shared tool integrations (bash/zsh)
##

# make less peek inside archives and other non-text files
if command -v lesspipe >/dev/null 2>&1; then
    eval "$(SHELL=/bin/sh lesspipe)"
fi

# colorize ls via LS_COLORS (honors ~/.dircolors if present)
if command -v dircolors >/dev/null 2>&1; then
    if [ -r "$HOME/.dircolors" ]; then
        eval "$(dircolors -b "$HOME/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi
fi

# direnv: per-directory env; hook syntax differs per shell
if command -v direnv >/dev/null 2>&1; then
    if [ -n "${ZSH_VERSION:-}" ]; then
        eval "$(direnv hook zsh)"
    elif [ -n "${BASH_VERSION:-}" ]; then
        eval "$(direnv hook bash)"
    fi
fi
