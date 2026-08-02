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

# free: human-readable on linux (procps); macos has no free(1), so build an
# approximation from vm_stat (used = active + wired + compressor pages, the
# same notion activity monitor uses)
if command -v free >/dev/null 2>&1; then
    free() {
        command free -h "$@"
    }
elif command -v vm_stat >/dev/null 2>&1; then
    free() {
        command vm_stat | command awk \
            -v total="$(command sysctl -n hw.memsize)" \
            -v pagesz="$(command sysctl -n hw.pagesize)" '
            { gsub(/\./, "", $NF) }
            /^Pages active/                 { used += $NF }
            /^Pages wired down/             { used += $NF }
            /^Pages occupied by compressor/ { used += $NF }
            END {
                gib = 1024 * 1024 * 1024
                used *= pagesz
                printf "%-5s %9s %9s %9s\n", "", "total", "used", "avail"
                printf "%-5s %8.1fG %8.1fG %8.1fG\n", "Mem:",
                    total / gib, used / gib, (total - used) / gib
            }'
    }
fi
