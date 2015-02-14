# record-region
Simple shell script to record a region of the linux desktop with byzanz and upload it

##Dependencies
You'll need a few programs installed for this script to work
* [byzanz](https://github.com/GNOME/byzanz) Screen-recording software
* [xrectsel](https://github.com/lolilolicon/xrectsel) Screen-area selector, found in ffcast2
* [zenity](https://github.com/GNOME/zenity) Prompt for duration of the recording in seconds.
* If you don't want to use pomf, you'll need a script that uploads for you.

## Usage

###Record to the default location (/tmp/recorded.webm) with the default time of 10 seconds:
    $ record-region.sh

###Record and upload to pomf.se:
    $ record-region.sh -u

###Record, and upload using a custom script:
    $ record-region.sh -c /path/to/uploader/script

After recording, the script will run `/path/to/uploader/script /location/of/recording`

This script doesn't necessarily have to be an uploader, just a script that is triggered after the recording is done.

Also, note that `-c` implies `-u`

###Record using a specified duration:
    $ record-region.sh -t 10

###OR launch a gui prompt for the duration (good for a keybinding)
    $ record-region.sh -p

###Store in a custom location
    $ record-region.sh -l /path/to/store.webm

###Choose a file format
    $ record-region.sh -f gif

Currently, byzanz-record supports webm (default), flv, gif, ogg, ogv, and byzanz.

Run `man byzanz-record` for more information.

###Record audio from the default input device
    $ record.region.sh -a

Note - Audio only works with webm (default), ogg, or ogv formats.