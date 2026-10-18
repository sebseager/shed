##
# bash/zsh exports
##

# fall back to xterm-256color when this host has no terminfo entry for $TERM
if command -v infocmp >/dev/null 2>&1 && ! infocmp "$TERM" >/dev/null 2>&1 &&
    infocmp xterm-256color >/dev/null 2>&1; then
    export TERM=xterm-256color
fi

# default editor and pager
export EDITOR=vim
export VISUAL="$EDITOR"
export PAGER=less

# less: keep colors, quit if one screen, don't clobber the screen on exit
export LESS='-FRX'

# true color, matches what interactive terminals advertise
export COLORTERM=truecolor

# let gpg/pinentry find the terminal when signing, iff stdin is a terminal
if tty -s 2>/dev/null; then
    export GPG_TTY="$(tty)"
fi

# colored gcc/g++ diagnostics
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
