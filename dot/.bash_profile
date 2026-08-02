# .bash_profile
# login shells may read this and not .bashrc, so defer to it here
# shed:bootstrap -- without it, login bash never reads .bashrc
#

[ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc"