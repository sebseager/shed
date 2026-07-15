##
# zsh shell initialization
##

# Note 1: zsh is stricter than bash about the order in which it's initialized, 
# so we put it all in one file instead of splitting it up like we do for bash

# Note 2: ZDOTDIR is defined in .zshenv

##
## fpath

ZSH_COMPLETIONS_DIR="$ZDOTDIR/completions"
mkdir -p "$ZSH_COMPLETIONS_DIR"

typeset -U fpath  # dedup fpath so harmless duplicates don't trigger rebuilds
fpath=("$ZSH_COMPLETIONS_DIR" $fpath)

##
## autoloads

autoload -Uz add-zsh-hook
autoload -Uz compinit  # completions
autoload -Uz compaudit
autoload -Uz vcs_info  # for prompt
autoload -Uz zrecompile

##
## zmodules

zmodload zsh/datetime  # for EPOCHREALTIME

##
## history

# zsh writes no history file unless HISTFILE + SAVEHIST are set
# not exported: the shell reads these for itself, not child processes, and
# exporting HISTFILE would leak into a child bash (it'd write here too)
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=100000               # events kept in memory for this session
SAVEHIST=100000               # events written to $HISTFILE
setopt HIST_IGNORE_SPACE      # drop commands that start with a space
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicate when a new one is added (erasedups)
setopt HIST_REDUCE_BLANKS     # trim redundant whitespace before saving
setopt EXTENDED_HISTORY       # record timestamp + duration per command
setopt HIST_VERIFY            # expand history into prompt buffer before running
setopt INC_APPEND_HISTORY     # append each command as it runs, not on exit
# swap INC_APPEND_HISTORY for SHARE_HISTORY to also sync live across open shells

##
## install tool completions

setopt COMPLETE_IN_WORD       # allow tab completion in the middle of a word

install_completion() {
    local name="$1" generator="$2" target="$ZSH_COMPLETIONS_DIR/_${name}"
    command -v "$name" >/dev/null 2>&1 || return 0

    # refresh if missing or if the binary is newer than the completion file
    if [[ ! -f "$target" || "$(command -v "$name")" -nt "$target" ]]; then
        # many generators include a '#compdef <name>' header, add one if not
        local tmp; tmp="$(mktemp)"
        "${(z)generator}" >| "$tmp"
        if ! grep -qE '^#\s*compdef\s+' "$tmp"; then
            printf '#compdef %s\n' "$name" | cat - "$tmp" >| "$target"
            rm -f -- "$tmp"
        else
            mv -f -- "$tmp" "$target"
        fi
    fi
}

install_completion docker  "docker completion zsh"
install_completion podman  "podman completion zsh"
install_completion gh      "gh completion --zsh"
unfunction install_completion

##
## init zsh completions (once fpath is ready and after all compdef calls)

ZSH_COMPDUMP="$ZDOTDIR/.zcompdump"
ZSH_COMPINIT_TTL=24

() {
    emulate -L zsh
    setopt extendedglob nullglob

    # exit if another shell is here
    if [[ -e $lock ]]; then
        local pid
        read -r pid < "$lock"
        if [[ -n $pid ]] && kill -0 "$pid" 2>/dev/null; then
            # another shell is initializing, use cached dump and exit early
            # kill -0 just returns success if the process exists (sends no signal)
            compinit -C -d "$ZSH_COMPDUMP"
            return
        fi
        rm -f -- "$lock"  # stale or bad lock, remove and proceed
    fi

    # grab the lock and ensure rm on exit
    mkdir -p ${ZSH_COMPDUMP:h}
    print -r -- $$ >| "$lock"
    trap 'rm -f "$lock"' EXIT

    # (re)init if missing or older than ZSH_COMPINIT_TTL hours
    if [[ ! -e $ZSH_COMPDUMP || -n "$ZSH_COMPDUMP"(#qN.mh+${ZSH_COMPINIT_TTL}) ]]; then
        if [[ ${ZSH_DISABLE_COMPFIX} != true ]]; then
            if insecure=$(compaudit 2>/dev/null); [[ -n $insecure ]]; then
                print -u2 -- "[zsh] Ignoring insecure completion directories:"
                print -u2 -- "$insecure"
                print -u2 -- "[zsh] Fix with: compaudit | xargs chmod g-w,o-w"
                compinit -i -d "$ZSH_COMPDUMP"  # init ignoring insecure paths
            else
                compinit -d "$ZSH_COMPDUMP"  # full-fat init
            fi
        else
            compinit -i -d "$ZSH_COMPDUMP"  # ZSH_DISABLE_COMPFIX skips compaudit
        fi
        # compile to bytecode (.zwc) in background for tiny speed boost
        (command -v zrecompile >/dev/null && zrecompile -q -p "$ZSH_COMPDUMP" 2>/dev/null) &
    else
        compinit -C -d "$ZSH_COMPDUMP"  # load existing dump quickly
        touch "$ZSH_COMPDUMP"           # nudge mtime to avoid herd rebuilds later
    fi
}

##
## prompt

# git info at the prompt; add-zsh-hook lets us register precmd non-destructively
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats $'\ue0a0 %b'            # current branch
zstyle ':vcs_info:git:*' actionformats $'\ue0a0 %b (%a)' # e.g. rebase, merge

# prompt_subst lets ${vcs_info_msg_0_} expand each time the prompt renders
setopt prompt_subst

# user, host, pwd and git branch on the line above the prompt
# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
# registered as a hook (not bare precmd) so it coexists with other precmd hooks
_shed_left_prompt_precmd() {
    vcs_info
    print -rP '%F{12}%n@%m%f %F{10}%B%2~%b%f  %F{11}${vcs_info_msg_0_}%f'
}
add-zsh-hook precmd _shed_left_prompt_precmd

# EPOCHREALTIME is "seconds.micros", we want "HH:MM:SS.mmm"
_shed_right_prompt_precmd() {
    local rt=$EPOCHREALTIME ms=${${rt#*.}[1,3]}   # first 3 digits
    RPROMPT=" %F{8}%D{%H:%M:%S}.${ms}%f"
}
add-zsh-hook precmd _shed_right_prompt_precmd

# the prompt line itself
PROMPT='%(?.%F{14}.%F{9})%(?..[%?] )%#%f '
