#!/bin/bash

#Original version found at https://github.com/kowalcj0/dotfiles/blob/master/usr/bin/byzanz-record-region.sh

#To run this script, you'll need:
#byzanz https://github.com/GNOME/byzanz
#ffcast2 https://github.com/lolilolicon/FFcast2
#zenity (gnome)
#An script to upload to the location of your choice

# Delay before starting
DELAY=3

# Sound notification to let one know when recording is about to start (and ends)
beep() {
    paplay /usr/share/sounds/KDE-Im-Irc-Event.ogg &     #Wouldn't be a bad idea to use our own.
}

uploadFlag='false'
place="/tmp/recorded.webm"


while getopts ':pu' flag; do
  case "${flag}" in
    u)uploadFlag='true' ;;
    p)D="--duration=$(zenity --entry --title='Record time' --text='Time in Seconds') /tmp/recorded.webm";;
    *) echo "error Unexpected option ${flag}" ;;
  esac
done

# Duration and output file
if [ -z "$D" ]; then
    echo Default recording duration 10s to /tmp/recorded.webm
    D="--duration=10 $place"
fi

# xrectsel from https://github.com/lolilolicon/FFcast2/blob/master/xrectsel.c
ARGUMENTS=$(xrectsel "--x=%x --y=%y --width=%w --height=%h") || exit -1

echo Delaying $DELAY seconds. After that, byzanz will start
for (( i=$DELAY; i>0; --i )) ; do
    echo $i
    sleep 1
done
beep
echo "$(tput setaf 2)Recording$(tput sgr0)"
byzanz-record --verbose --delay=0 ${ARGUMENTS} $D
beep
#beeps after recording is done, but whatever
if [ $uploadFlag == "true" ]; then
    upload -u $place
fi
