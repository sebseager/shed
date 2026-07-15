# .zshrc
# shed bootstrapper, symlinked from shed/dot/.zshrc, read by interactive zsh
#

# locate shed by resolving this file's symlink chain
_shed_src="${(%):-%N}"
while [ -L "$_shed_src" ]; do
    _shed_link="$(readlink "$_shed_src")"
    case "$_shed_link" in
        /*) _shed_src="$_shed_link" ;;
        *)  _shed_src="${_shed_src:h}/$_shed_link" ;;
    esac
done
export SHED_ROOT="${_shed_src:A:h:h:h}"
echo "SHED_ROOT: $SHED_ROOT"
unset _shed_src _shed_link

if [ ! -d "$SHED_ROOT/bin" ]; then
    printf 'shed: could not locate shed root (got "%s")\n' "$SHED_ROOT" >&2
    return 0
fi

# os detection via bin/whatsmyos
SHED_OS="$(bash "$SHED_ROOT/bin/whatsmyos" 2>/dev/null || echo unknown)"
export SHED_OS

# PATH: shed bin/ and os/<os>/bin highest, then ~/.local/bin, dedup-guarded
_shed_addpath() {
    [ -d "$1" ] || return 0
    case ":$PATH:" in *":$1:"*) return 0 ;; esac
    PATH="$1:$PATH"
}
_shed_addpath "$HOME/.local/bin"
_shed_addpath "$SHED_ROOT/os/$SHED_OS/bin"
_shed_addpath "$SHED_ROOT/bin"
export PATH

# source fragments: shared (.sh) then zsh-specific (.zsh)
_shed_source_dir() {
    local d="$1" ext="$2" f
    [ -d "$d" ] || return 0
    for f in "$d"/*."$ext"(N); do
        [ -r "$f" ] && source "$f"
    done
}
_shed_source_dir "$SHED_ROOT/shell"         sh
_shed_source_dir "$SHED_ROOT/shell"         zsh
_shed_source_dir "$SHED_ROOT/private/shell" sh     # secrets live here
_shed_source_dir "$SHED_ROOT/private/shell" zsh

# machine-specific, untracked
[ -r "$HOME/.zshrc" ] && source "$HOME/.zshrc"
[ -r "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
[ -r "$ZDOTDIR/.zshrc.local" ] && source "$HOME/.zshrc.local"

# check to make sure shed is still on path
if [[ $- == *i* && -n ${SHED_ROOT:-} ]]; then
    (( ! ${path[(I)$SHED_ROOT/bin]} )) && 
        print -u2 "shed: $SHED_ROOT/bin is not on PATH after bootstrapping!"
fi

unfunction _shed_addpath _shed_source_dir