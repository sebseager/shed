##
# bash prompt configuration
##

# trim \w to the last 2 path components, like zsh's %2~
PROMPT_DIRTRIM=2

# echo "  <glyph> <branch>" when inside a git work tree, else nothing
_shed_git_branch() {
    local branch
    branch=$(git branch --show-current 2>/dev/null)
    [ -n "$branch" ] && printf '  \ue0a0 %s' "$branch"
}

# colorize the prompt char by last exit status.
# raw \001/\002 (not \[ \]) because these are inserted via parameter expansion,
# after bash has already decoded the prompt escapes.
_shed_ps_col=''
_shed_ps_code=''
_shed_prompt_command() {
    local last=$?
    if [ "$last" -eq 0 ]; then
        _shed_ps_col=$'\001\e[96m\002'      # bright cyan on success
        _shed_ps_code=''
    else
        _shed_ps_col=$'\001\e[91m\002'      # bright red on failure
        _shed_ps_code="[$last] "
    fi
}

# register without clobbering an existing PROMPT_COMMAND (e.g. direnv's hook)
case "${PROMPT_COMMAND:-}" in
    *_shed_prompt_command*) ;;
    '') PROMPT_COMMAND='_shed_prompt_command' ;;
    *)  PROMPT_COMMAND='_shed_prompt_command; '"$PROMPT_COMMAND" ;;
esac

# info line (user@host, cwd, branch), then the prompt char
PS1='\[\e[94m\]\u@\h\[\e[0m\] \[\e[1;92m\]\w\[\e[0m\]\[\e[93m\]$(_shed_git_branch)\[\e[0m\]\n'
PS1+='${_shed_ps_col}${_shed_ps_code}\$\[\e[0m\] '
