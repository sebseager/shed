# .bashrc
# shed bootstrapper, symlinked from shed/dot/.bashrc, read by interactive bash
# shed:bootstrap -- wires shed bin dirs onto PATH
#

# locate shed by resolving this file's symlink chain. a preset SHED_ROOT (from
# the environment or a parent shell) is kept as a last-resort fallback in case
# resolution fails -- shed install guarantees real symlinks (refusing to run
# where msys ln -s would copy), but a link can still go stale or get clobbered
_shed_preset="${SHED_ROOT:-}"
_shed_src="${BASH_SOURCE[0]}"
while [ -L "$_shed_src" ]; do
    _shed_link="$(readlink "$_shed_src")"
    _shed_link="${_shed_link//\\//}"    # windows readlink may emit backslashes
    case "$_shed_link" in
        /*|[A-Za-z]:/*) _shed_src="$_shed_link" ;;    # absolute (posix or windows)
        *)              _shed_src="$(dirname "$_shed_src")/$_shed_link" ;;
    esac
done
SHED_ROOT="$(cd "$(dirname "$_shed_src")/.." >/dev/null 2>&1 && pwd)"

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
    return 0 2>/dev/null || true
fi

# os detection via bin/whatsmyos
SHED_OS="$(bash "$SHED_ROOT/bin/whatsmyos" 2>/dev/null || echo unknown)"
export SHED_OS

# PATH: shed bin/ and os/<os>/bin highest, then ~/.local/bin. shed_path_add
# (shared with shell/path.sh and machine-local rc files) is defined in
# shell/lib/pathadd.sh -- see there for the move-to-front rationale
. "$SHED_ROOT/shell/lib/pathadd.sh"
shed_path_add "$HOME/.local/bin"
shed_path_add "$SHED_ROOT/os/$SHED_OS/bin"
shed_path_add "$SHED_ROOT/bin"
export PATH

# source fragments: shared (.sh) then bash-specific (.bash)
_shed_source_dir() {
    local d="$1" ext="$2" f
    [ -d "$d" ] || return 0
    for f in "$d"/*."$ext"; do
        [ -r "$f" ] && . "$f"
    done
}
_shed_source_dir "$SHED_ROOT/shell"         sh
_shed_source_dir "$SHED_ROOT/shell"         bash
_shed_source_dir "$SHED_ROOT/private/shell" sh     # secrets live here
_shed_source_dir "$SHED_ROOT/private/shell" bash

# machine-specific, untracked
[ -r "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"

# re-assert shed PATH precedence: anything sourced above may have overwritten
# PATH wholesale. set SHED_NO_PATH_REASSERT=1 (e.g. in .bashrc.local) to let a
# later script's PATH stand
if [ -z "${SHED_NO_PATH_REASSERT:-}" ]; then
    case ":$PATH:" in
        *":$SHED_ROOT/bin:"*) ;;
        *) printf 'shed: PATH was reset while sourcing rc files; re-adding shed entries\n' >&2 ;;
    esac
    shed_path_add "$HOME/.local/bin"
    shed_path_add "$SHED_ROOT/os/$SHED_OS/bin"
    shed_path_add "$SHED_ROOT/bin"
    export PATH
fi

# check to make sure shed is still on path
if [[ $- == *i* && -n ${SHED_ROOT:-} ]]; then
    [[ :$PATH: != *":$SHED_ROOT/bin:"* ]] &&
        printf 'shed: %s/bin is not on PATH after bootstrapping!\n' "$SHED_ROOT" >&2
fi

# shed_path_add stays defined for interactive use and later local rc files
unset -f _shed_source_dir