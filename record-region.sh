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
    paplay bell.ogg &     #Wouldn't be a bad idea to use our own.
}

uploadFlag='false'
location="/tmp/recorded.webm"
duration="10"
uploadCmd="upload"

while getopts ':put:l:' flag; do
  case "${flag}" in
    l)location="$OPTARG" ;;
    t)duration="$OPTARG" ;;
    u)uploadFlag='true' ;;
    p)duration="$(zenity --entry --title='Record time' --text='Time in Seconds')" || exit -1;;
    *) echo "error Unexpected option ${flag}" ;;
  esac
done

#Make sure we're writable
if [[ -a $location ]]; then
    if [[ ! -w $location ]]; then
        echo "Could not write to $location"
    fi
elif [[ ! -w $(dirname ${location}) ]]; then
    echo "Could not write to $(dirname ${location})"
fi

# xrectsel from https://github.com/lolilolicon/FFcast2/blob/master/xrectsel.c
ARGUMENTS=$(xrectsel "--x=%x --y=%y --width=%w --height=%h") || exit -1

echo Delaying $DELAY seconds. After that, byzanz will start
for (( i=$DELAY; i>0; --i )) ; do
    echo $i
    sleep 1
done
beep
echo "$(tput setaf 2)Recording$(tput sgr0) with duration $duration and storing to $location"
byzanz-record --verbose --delay=0 ${ARGUMENTS} --duration=$duration $location || exit -1

beep #beeps after recording is done, but whatever

if [ $uploadFlag == "true" ]; then
    exec $uploadCmd -u $location || exit -1
fi
