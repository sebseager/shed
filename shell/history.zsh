##
# zsh-only exports
##

# history
# zsh writes no history file unless HISTFILE + SAVEHIST are set
# not exported: the shell reads these for itself, not child processes, and
# exporting HISTFILE would leak into a child bash (it'd write here too)
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000        # events kept in memory for this session
SAVEHIST=100000        # events written to $HISTFILE
setopt HIST_IGNORE_SPACE      # drop commands that start with a space
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicate when a new one is added (erasedups)
setopt HIST_REDUCE_BLANKS     # trim redundant whitespace before saving
setopt EXTENDED_HISTORY       # record timestamp + duration per command
setopt INC_APPEND_HISTORY     # append each command as it runs, not on exit
# swap the line above for SHARE_HISTORY to also sync live across open shells
