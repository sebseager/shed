##
# bash/zsh exports
##

# default editor and pager
export EDITOR=vim
export VISUAL="$EDITOR"
export PAGER=less

# less: keep colors, quit if one screen, don't clobber the screen on exit
export LESS='-FRX'

# true color, matches what interactive terminals advertise
export COLORTERM=truecolor

# let gpg/pinentry find the terminal when signing
export GPG_TTY="$(tty)"
