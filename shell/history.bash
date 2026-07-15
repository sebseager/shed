##
# bash history
##

export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT='%F %T '

# append across sessions instead of overwriting history file on exit
shopt -s histappend