#!/bin/bash

full_screenshot() {
    dir="$HOME/Pictures/Screenshot/"
    mkdir -p "$dir"
    
    FILE="$dir$(date +%Y-%m-%dT%H:%M:%S,%N%:z).png"
    
    grimblast copysave screen "$FILE"
    notify-send "Screenshot Taken" "$(basename "$FILE")" -i "$FILE" -t 3000
}
area_screenshot() {
    dir="$HOME/Pictures/Screencut/"
    mkdir -p "$dir"

    FILE="$dir$(date +%Y-%m-%dT%H:%M:%S,%N%:z).png"


    grimblast copysave area "$FILE"
    notify-send "Screenshot Taken" "$(basename "$FILE")" -i "$FILE" -t 3000
}
copy_clipboard() {
    grimblast --notify copy
}

if [[ "$1" == "full" ]]; then
    full_screenshot
elif [[ "$1" == "area" ]]; then
    area_screenshot
elif [[ "$1" == "copy" ]]; then
    copy_clipboard
else
    echo "Usage: $0 full|area"
fi
