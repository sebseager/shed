##
# zsh prompt configuration
##

# git info at the prompt; add-zsh-hook lets us register precmd non-destructively
autoload -Uz vcs_info add-zsh-hook  # be careful not to run these twice
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats $'\ue0a0 %b'            # current branch
zstyle ':vcs_info:git:*' actionformats $'\ue0a0 %b (%a)' # e.g. rebase, merge

# prompt_subst lets ${vcs_info_msg_0_} expand each time the prompt renders
setopt prompt_subst

# user, host, pwd and git branch on the line above the prompt
# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
# registered as a hook (not bare precmd) so it coexists with other precmd hooks
_shed_prompt_precmd() {
    vcs_info
    print -rP '%F{12}%n@%m%f %F{10}%B%2~%b%f  %F{11}${vcs_info_msg_0_}%f'
}
add-zsh-hook precmd _shed_prompt_precmd

# the prompt line itself
PROMPT='%(?.%F{14}.%F{9})%(?..[%?] )%#%f '
RPROMPT=' %F{8}%D{%K:%M:%S.%3.}%f'
