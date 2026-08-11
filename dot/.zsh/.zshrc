# .zshrc
# shed bootstrapper, symlinked from shed/dot/.zsh/.zshrc to $ZDOTDIR/.zshrc,
# read by interactive zsh
# shed:bootstrap -- wires shed bin dirs onto PATH
#

# locate shed by resolving this file's symlink chain. a preset SHED_ROOT (from
# the environment or a parent shell) is kept as a last-resort fallback in case
# resolution fails -- shed install guarantees real symlinks (refusing to run
# where msys ln -s would copy), but a link can still go stale or get clobbered
_shed_preset="${SHED_ROOT:-}"
_shed_src="${(%):-%N}"
while [ -L "$_shed_src" ]; do
    _shed_link="$(readlink "$_shed_src")"
    _shed_link="${_shed_link//\\//}"    # windows readlink may emit backslashes
    case "$_shed_link" in
        /*|[A-Za-z]:/*) _shed_src="$_shed_link" ;;    # absolute (posix or windows)
        *)              _shed_src="${_shed_src:h}/$_shed_link" ;;
    esac
done
SHED_ROOT="${_shed_src:A:h:h:h}"

# validate against a sentinel file, not a bare -d bin test: when resolution
# collapses to a filesystem root (copied rc file + HOME=/root gives
# SHED_ROOT=/), a stray bin/ directory exists and -d passes wrongly
if [ ! -f "$SHED_ROOT/bin/whatsmyos" ]; then
    SHED_ROOT="$_shed_preset"
fi
export SHED_ROOT
unset _shed_src _shed_link _shed_preset

if [ ! -f "$SHED_ROOT/bin/whatsmyos" ]; then
    printf 'shed: could not locate shed root (got "%s"); export SHED_ROOT to override\n' "$SHED_ROOT" >&2
    return 0
fi

# os detection via bin/whatsmyos
SHED_OS="$(bash "$SHED_ROOT/bin/whatsmyos" 2>/dev/null || echo unknown)"
export SHED_OS

# PATH: shed bin/ and os/<os>/bin highest, then ~/.local/bin. shed_path_add
# (shared with shell/path.sh and machine-local rc files) is defined in
# shell/lib/pathadd.sh -- see there for the move-to-front rationale
source "$SHED_ROOT/shell/lib/pathadd.sh"
shed_path_add "$HOME/.local/bin"
shed_path_add "$SHED_ROOT/os/$SHED_OS/bin"
shed_path_add "$SHED_ROOT/bin"
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
[ -r "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
[ -r "$ZDOTDIR/.zshrc.local" ] && source "$ZDOTDIR/.zshrc.local"

# re-assert shed PATH precedence: anything sourced above may have overwritten
# PATH wholesale. set SHED_NO_PATH_REASSERT=1 (e.g. in .zshrc.local) to let a
# later script's PATH stand
if [ -z "${SHED_NO_PATH_REASSERT:-}" ]; then
    case ":$PATH:" in
        *":$SHED_ROOT/bin:"*) ;;
        *) print -u2 "shed: PATH was reset while sourcing rc files; re-adding shed entries" ;;
    esac
    shed_path_add "$HOME/.local/bin"
    shed_path_add "$SHED_ROOT/os/$SHED_OS/bin"
    shed_path_add "$SHED_ROOT/bin"
    export PATH
fi

# check to make sure shed is still on path
if [[ $- == *i* && -n ${SHED_ROOT:-} ]]; then
    (( ! ${path[(I)$SHED_ROOT/bin]} )) &&
        print -u2 "shed: $SHED_ROOT/bin is not on PATH after bootstrapping!"
fi

# shed_path_add stays defined for interactive use and later local rc files
unfunction _shed_source_dir