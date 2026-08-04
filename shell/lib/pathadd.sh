##
# shed_path_add -- shared PATH helper (bash/zsh)
# sourced by the rc bootstraps right after SHED_ROOT is located, so it is
# available to shell/ fragments (path.sh) and machine-local rc files alike.
# lives in shell/lib/ so the shell/*.sh fragment glob doesn't source it twice
##

# move $1 to the front of PATH, removing any existing occurrences first, and
# skip dirs that don't exist on this machine. an entry already on PATH is
# moved, not skipped: macos path_helper demotes inherited entries in nested
# login shells (e.g. tmux), so presence alone doesn't guarantee precedence.
# intentionally left defined after init so ~/.zshrc.local & co. can use it
shed_path_add() {
    [ -d "$1" ] || return 0
    local p=":$PATH:"
    while [ "${p#*:"$1":}" != "$p" ]; do
        p="${p%%:"$1":*}:${p#*:"$1":}"
    done
    p="${p#:}"; p="${p%:}"
    if [ -n "$p" ]; then PATH="$1:$p"; else PATH="$1"; fi
}
