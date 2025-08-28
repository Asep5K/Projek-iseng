#!/bin/bash

theme="$HOME/.config/rofi/themes/screenshoot.rasi"
scr="./scr.sh"
rc="./record.sh"
pid="/tmp/toggle_recording.pid"

if [ -f "$pid" ]; then
    record_status="RECORDING ■"   # pakai simbol kotak buat stop
else
    record_status="RECORDING ▶"  # pakai simbol play buat start
fi

options="FULL\nAREA\nCLIPBOARD\n$record_status"
choice=$(echo -e "$options" | rofi -dmenu -p "    SCREENSHOOT/RECORD" -theme "$theme")




case "$choice" in
    "FULL") $scr full ;;
    "AREA") $scr area ;;
    "CLIPBOARD") $scr copy ;;
    *RECORDING*) $rc ;;
esac 