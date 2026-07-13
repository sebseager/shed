##
# bash history config
##

# history: large, deduped, timestamped
export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT='%F %T '

# append across sessions instead of overwriting the history file on exit
shopt -s histappend