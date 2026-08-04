##
# PATH additions for tools installed outside shed (bash/zsh)
# shed_path_add comes from shell/lib/pathadd.sh, sourced by the rc bootstraps
# before any shell/ fragment
##

# listed lowest precedence first: each dir is moved to the front, so later
# entries win. shed's own bin dirs and ~/.local/bin are re-asserted above all
# of these at the end of the rc bootstrap
for _shed_dir in \
    /opt/homebrew/sbin \
    /opt/homebrew/opt/rustup/bin \
    /opt/homebrew/bin \
    "$HOME/.local/share/mise/shims" \
    "$HOME/.perl5/bin"
do
    shed_path_add "$_shed_dir"
done
unset _shed_dir
export PATH
