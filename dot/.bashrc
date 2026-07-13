# .bashrc
# shed bootstrapper, symlinked from shed/dot/.bashrc, read by interactive bash
#

# locate shed by resolving this file's symlink chain
_shed_src="${BASH_SOURCE[0]}"
while [ -L "$_shed_src" ]; do
    _shed_link="$(readlink "$_shed_src")"
    case "$_shed_link" in
        /*) _shed_src="$_shed_link" ;;
        *)  _shed_src="$(dirname "$_shed_src")/$_shed_link" ;;
    esac
done
SHED_ROOT="$(cd "$(dirname "$_shed_src")/.." >/dev/null 2>&1 && pwd)"
export SHED_ROOT
unset _shed_src _shed_link

if [ ! -d "$SHED_ROOT/bin" ]; then
    printf 'shed: could not locate shed root (got "%s")\n' "$SHED_ROOT" >&2
    return 0 2>/dev/null || true
fi

# os detection via bin/whatsmyos
SHED_OS="$(bash "$SHED_ROOT/bin/whatsmyos" 2>/dev/null || echo unknown)"
export SHED_OS

# PATH: os/<os>/bin then bin/, dedup-guarded
_shed_addpath() {
    [ -d "$1" ] || return 0
    case ":$PATH:" in *":$1:"*) return 0 ;; esac
    PATH="$1:$PATH"
}
_shed_addpath "$SHED_ROOT/os/$SHED_OS/bin"
_shed_addpath "$SHED_ROOT/bin"
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

unset -f _shed_addpath _shed_source_dir