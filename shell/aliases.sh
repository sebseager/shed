##
# bash/zsh aliases
##

alias ll='ls -lah'
alias vi='vim'
alias rsync='rsync -avzh --progress'
alias k9='kill -9'
alias big='du -am | sort -nr | head -n 20'
alias weather='curl "v2d.wttr.in/?F"'

# ls: color-capable on both gnu (linux/wsl) and bsd (macos)
if ls --color=auto >/dev/null 2>&1; then
    alias ls='ls --color=auto'
else
    alias ls='ls -G'
fi
alias la='ls -A'
alias l='ls -CF'

# always-color grep
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# human-readable sizes (free lives in functions.sh: macos needs a real shim)
alias df='df -h'
alias du='du -h'

# git shortcuts
alias g='git'
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gco='git checkout'
alias gsw='git switch'
alias gb='git branch'
alias gl='git log --oneline --graph --decorate'

# misc
alias path='echo "$PATH" | tr ":" "\n"'
alias reload='exec "$SHELL" -l'

# listening sockets: ss on linux, lsof on macos/bsd
if command -v ss >/dev/null 2>&1; then
    alias ports='ss -tulpn'
else
    alias ports='lsof -nP -iTCP -sTCP:LISTEN'
fi
