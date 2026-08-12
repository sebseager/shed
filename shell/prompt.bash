##
# bash prompt
##

# trim \w to the last 2 path components, like zsh's %2~
PROMPT_DIRTRIM=2

# colorize the prompt char by last exit status, and refresh the git branch
# segment ("  <glyph> <branch>" inside a git work tree, else empty).
# raw \001/\002 (not \[ \]) because these are inserted via parameter expansion,
# after bash has already decoded the prompt escapes.
# the branch is computed here and expanded from a variable instead of a
# $(...) directly in PS1: msys2 bash (git bash on windows) mis-parses a
# command substitution in a PS1 that also contains a \n escape, erroring at
# every prompt (msys2/MSYS2-packages#1839)
_shed_ps_col=''
_shed_ps_code=''
_shed_git_branch=''
_shed_prompt_command() {
    local last=$?
    if [ "$last" -eq 0 ]; then
        _shed_ps_col=$'\001\e[96m\002'      # bright cyan on success
        _shed_ps_code=''
    else
        _shed_ps_col=$'\001\e[91m\002'      # bright red on failure
        _shed_ps_code="[$last] "
    fi
    local branch
    branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        # U+E0A0 (powerline branch glyph) as raw utf-8 bytes: printf's \u
        # converts via the locale and degrades to literal "\ue0a0" where that
        # fails (msys2 bash without a utf-8 LANG); \u also needs bash >= 4.2
        printf -v _shed_git_branch '  \xee\x82\xa0 %s' "$branch"
    else
        _shed_git_branch=''
    fi
}

# register without clobbering an existing PROMPT_COMMAND (e.g. direnv's hook)
case "${PROMPT_COMMAND:-}" in
    *_shed_prompt_command*) ;;
    '') PROMPT_COMMAND='_shed_prompt_command' ;;
    *)  PROMPT_COMMAND='_shed_prompt_command; '"$PROMPT_COMMAND" ;;
esac

# info line (user@host, cwd, branch), then the prompt char
PS1='\[\e[94m\]\u@\h\[\e[0m\] \[\e[1;92m\]\w\[\e[0m\]\[\e[93m\]${_shed_git_branch}\[\e[0m\]\n'
PS1+='${_shed_ps_col}${_shed_ps_code}\$\[\e[0m\] '