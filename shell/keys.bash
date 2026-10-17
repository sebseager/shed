##
# bash key bindings
##

# bind common sequences rather than relying on system /etc/inputrc.
# bind warns outside interactive shells, where there's no line editor.
if [[ $- == *i* ]]; then
    bind '"\e[H": beginning-of-line'      # home (xterm-style)
    bind '"\eOH": beginning-of-line'      # home (xterm-style, keypad mode)
    bind '"\e[1~": beginning-of-line'     # home (vt220/tmux/screen)
    bind '"\e[7~": beginning-of-line'     # home (rxvt)
    bind '"\e[F": end-of-line'            # end
    bind '"\eOF": end-of-line'            # end
    bind '"\e[4~": end-of-line'           # end
    bind '"\e[8~": end-of-line'           # end
    bind '"\e[3~": delete-char'           # delete
    bind '"\e[1;5D": backward-word'       # ctrl-left (xterm-style)
    bind '"\e[1;5C": forward-word'        # ctrl-right
    bind '"\e[3;5~": kill-word'           # ctrl-delete
    bind '"\eOd": backward-word'          # ctrl-left (rxvt)
    bind '"\eOc": forward-word'           # ctrl-right
    bind '"\e[3^": kill-word'             # ctrl-delete
fi
