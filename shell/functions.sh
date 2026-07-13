##
# bash/zsh functions
##

# IMPORTANT: prefix ANYTHING shadowed by an alias with `command` to ignore
#            the alias and keep behavior stable within functions.

# make a directory (and parents) then cd into it
mkcd() {
    command mkdir -p -- "$1" && cd -- "$1" || return
}

# go up n directories (default 1), e.g. `up 3`
up() {
    local n="${1:-1}" p=""
    while [ "$n" -gt 0 ]; do p="../$p"; n=$((n - 1)); done
    cd "$p" || return
}

# make a timestamped backup copy of a file
bak() {
    command cp -a -- "$1" "$1.bak.$(date +%Y%m%d%H%M%S)"
}

# unpack most archive types by extension
extract() {
    [ -f "$1" ] || { echo "extract: '$1' is not a file" >&2; return 1; }
    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz)   tar xzf "$1" ;;
        *.tar.xz)         tar xJf "$1" ;;
        *.tar)            tar xf  "$1" ;;
        *.bz2)            bunzip2 "$1" ;;
        *.gz)             gunzip  "$1" ;;
        *.zip)            unzip   "$1" ;;
        *.7z)             7z x    "$1" ;;
        *.Z)              uncompress "$1" ;;
        *) echo "extract: don't know how to unpack '$1'" >&2; return 1 ;;
    esac
}

# quick static http server in the current dir (default port 8000)
serve() {
    python3 -m http.server "${1:-8000}"
}
