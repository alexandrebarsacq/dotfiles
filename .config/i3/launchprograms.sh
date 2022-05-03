#!/bin/bash
#
# This script is here because lauching app directly from i3 config has
# erratic behavior, probably because there is no control of what is 
# actually launched before continuing the actions. This scripts ensures 
# that a program is effectively launched before continuing 
# With my sauce, but stolen from : 
# https://github.com/yedhin
# Feel free to share with your friends

# install wmctrl. Its a prerequisite to make this script work.

# Launch it in your i3 config file
# exec --no-startup-id ~/.config/i3/init_workspace.sh
#
# obviously, make it executable : # chmod +x init_workspace.sh
# HAVE FUN !

# App you want to start :
apps=(
 "/usr/bin/firefox" 
 "/usr/bin/alacritty"
 #Create a scratchpad (accessible win $mod+w) with vimwiki started. 
 #This terminal will be put in scratchpad because of config rule on title "scratchpadterm"
 "/usr/bin/alacritty -t scratchpadterm --working-directory "/home/alexandre/vimwiki" --command /home/linuxbrew/.linuxbrew/bin/nvim /home/alexandre/vimwiki/index.md -c \"cd /home/alexandre/vimwiki\""
)

# Which workspace to assign your wanted App :
workspaces=(
"1" "2" "9"
)

# counter of opened windows
owNB=$(wmctrl -l | wc -l) # Get number of actual opened windows
startOwNB=$owNB

for iwin in ${!apps[*]}
do
    i3-msg workspace ${workspaces[$iwin]} # move in wanted workspace
    ${apps[$iwin]} & # start the wanted app

    while [ "$owNB" -lt "$((iwin + 1 + startOwNB))" ] # wait before start other programs
    do
        owNB=$(wmctrl -l | wc -l) # Get number of actual opened windows
    done
done

#Start in workspace 1
i3-msg workspace 1

