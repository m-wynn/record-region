#!/bin/bash

#Original version found at https://github.com/kowalcj0/dotfiles/blob/master/usr/bin/byzanz-record-region.sh

#To run this script, you'll need:
#byzanz https://github.com/GNOME/byzanz
#ffcast2 https://github.com/lolilolicon/FFcast2
#zenity (gnome)
#An script to upload to the location of your choice

# Delay before starting
DELAY=3

#Muffle a warning about accessibility bus.
export NO_AT_BRIDGE=1

# Sound notification to let one know when recording is about to start (and ends)
beep() {
    paplay "$(dirname $(readlink -f $0))/bell.ogg" &
}

uploadFlag='false'
location=""
format=""
audio=""
duration="10"
uploadCmd="false"

while getopts ':aput:l:c:f:' flag; do
  case "${flag}" in
    f)format="$OPTARG" ;;
    c)uploadCmd="$OPTARG"
      which $uploadCmd >/dev/null || exit -1
      ;;
    l)location="$OPTARG" ;;
    t)duration="$OPTARG" ;;
    u)uploadCmd='defaultpomf' ;;
    p)duration="$(zenity --entry --title='Record time' --text='Time in Seconds')" || exit -1;;
    a)audio="-a" || exit -1;;
    *) echo "error Unexpected option ${flag}" && exit -1;;
  esac
done

if [ -n "$format" ]; then
    if [ "$format" != "webm" ] && [ "$format" != "ogg" ] && [ "$format" != "ogv" ]; then
        if [ "$format" != "gif" ] && [ "$format" != "byzanz" ] && [ "$format" != "flv" ];then
            echo "Unsupported format ${format}"
            exit -1
        elif [ -n "$audio" ];then
            echo "${format} does not support recording audio."
            exit -1
        fi
    fi

    if [ -z $location ]; then
        location="/tmp/recorded.${format}"
    else
        echo "Ignoring -f flag.  Format is autodetected from -l filename"
    fi
else
    if [ -z $location]; then
        location="/tmp/recorded.webm"
    fi
fi

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
byzanz-record --verbose --delay=0 ${audio} ${ARGUMENTS} --duration=$duration $location | while read -r line ; do
    if [[ $line == "Recording completed. Finishing encoding..." ]]; then
        beep
        echo "Encoding recording"
    fi
done
echo "Encoding complete!"

if [ $uploadCmd == "defaultpomf" ]; then
    #heavily inspired by https://github.com/JSchilli1/poomf.sh
    # upload it and grab the url
    output=$(curl -F files[]="@$location" "http://pomf.se/upload.php")

    echo "Uploading ${location} to pomf..."
    pomffilename=""

    if [[ "${output}" =~ '"success":true,' ]]; then
        pomffilename=$(printf $output | grep -Eo '"url":"[A-Za-z0-9]+.*",' | sed 's/"url":"//;s/",//')
        echo "$pomffilename"
        echo  "Upload Completed"
        urlname="http://a.pomf.se/$pomffilename"
        echo "$urlname"
        echo -n $urlname | xclip -selection primary
        echo -n $urlname | xclip -selection clipboard
        xdg-open "$urlname"
        notify-send "Upload Successful" "$urlname"
    else
        echo  "Upload failed"
    fi
elif [ $uploadCmd != "false" ]; then
    exec $uploadCmd $location
fi
