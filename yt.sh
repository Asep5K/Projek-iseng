#!/bin/bash

# 🎨 Themes
theme1="$HOME/.config/rofi/themes/yt-dlp.rasi"
theme2="$HOME/.config/rofi/themes/list.rasi"
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"

# 📥 Input URL
url=$(rofi -dmenu -p "Enter YouTube URL:" -theme "$theme1")

# 🔎 Validate URL
if [[ ! "$url" =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
    notify-send -t 3000 "Invalid URL" "Only YouTube links are allowed!"
    exit 1
fi

# 📌 Get video title
title=$(yt-dlp --print title "$url" | head -n1)

# 📌 Menu options
options="Download MP3\nBest Quality Video\nChoose Resolution"
choice=$(echo -e "$options" | rofi -dmenu -p "Select option:" -theme "$theme1")

# 🎵 Audio only
mp3() {
    outdir="$HOME/Music"
    mkdir -p "$outdir"
    notify-send "🎵 Downloading..." "Audio (MP3)"

    yt-dlp -x --audio-format mp3 \
        -o "$outdir/%(title)s.%(ext)s" \
        "$url"

    notify-send "Download complete" "$title (MP3)"
}

# 🎬 Best quality video
bestvideo() {
    outdir="$HOME/Videos"
    mkdir -p "$outdir"
    notify-send "🎬 Downloading..." "Best quality video"

    yt-dlp -f bestvideo+bestaudio/best --merge-output-format mp4 \
        -o "$outdir/%(title)s.%(ext)s" \
        "$url"

    notify-send "Download complete" "$title"
}

# 🎚️ Manual resolution
choose() {
    outdir="$HOME/Downloads"
    mkdir -p "$outdir"

    notify-send "Fetching..." "Available formats"
    format=$(yt-dlp -F "$url" | rofi -dmenu -p "Choose format:" -theme "$theme2")
    [ -z "$format" ] && exit 0

    format_id=$(echo "$format" | awk '{print $1}')
    notify-send "🎬 Downloading..." "Format $format_id"

    yt-dlp -f "$format_id"+bestaudio/best \
        -o "$outdir/%(title)s.%(ext)s" \
        "$url"

    notify-send "Download complete" "$title"
}

# 🔀 Dispatcher
case "$choice" in
    "Download MP3") mp3 ;;
    "Best Quality Video") bestvideo ;;
    "Choose Resolution") choose ;;
    *) notify-send "❌ Error" "Unrecognized option!" ; exit 1 ;;
esac
