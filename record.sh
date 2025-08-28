#!/bin/bash

# 📁 Folder hasil rekaman
SAVE_DIR="$HOME/Videos/Recordings"
mkdir -p "$SAVE_DIR"
f="$HOME/Pictures/kurumi/foto_008.jpg"

# 📄 File penanda recording aktif
PID_FILE="/tmp/toggle_recording.pid"

if [ ! -f "$PID_FILE" ]; then
    # 🔴 Belum rekam → MULAI REKAMAN

    # 🕒 Nama file unik
    FILENAME="record_$(date +'%Y-%m-%d_%H-%M-%S')"
    VIDEO_FILE="$SAVE_DIR/${FILENAME}.mp4"
    AUDIO_FILE="$SAVE_DIR/${FILENAME}.wav"
    FINAL_FILE="$SAVE_DIR/${FILENAME}_final.mp4"

    # 🔊 Audio dari device/output (bukan mic)
    AUDIO_SOURCE="alsa_output.pci-0000_00_1b.0.analog-stereo.monitor"

    # 🧠 Simpan path file sementara (biar bisa diakses pas stop)
    echo "$VIDEO_FILE;$AUDIO_FILE;$FINAL_FILE" > /tmp/toggle_recording_files

    # ▶️ Rekam audio di background
    parec -d "$AUDIO_SOURCE" --format=s16le --rate=48000 --channels=2 > "$AUDIO_FILE" &
    AUDIO_PID=$!

    # 🎥 Rekam video di background
    wf-recorder -f "$VIDEO_FILE" &
    VIDEO_PID=$!

    # Simpan PID kedua proses
    echo "$VIDEO_PID:$AUDIO_PID" > "$PID_FILE"

    notify-send -t 2000 -i "$f" "🔴 Recording started" "Press the shortcut again to stop"

else
    # 🟢 Sedang rekam → HENTIKAN + GABUNG

    # Ambil PID
    IFS=":" read VIDEO_PID AUDIO_PID < "$PID_FILE"
    IFS=";" read VIDEO_FILE AUDIO_FILE FINAL_FILE < /tmp/toggle_recording_files

    # Kill secara elegan
    kill "$VIDEO_PID" 2>/dev/null
    kill "$AUDIO_PID" 2>/dev/null

    # Tunggu proses selesai
    wait "$VIDEO_PID"
    wait "$AUDIO_PID"

    # Gabungin
    notify-send -i "$f" "🔄 Merging audio + video..."
    ffmpeg -y -i "$VIDEO_FILE" -f s16le -ar 48000 -ac 2 -i "$AUDIO_FILE" \
           -c:v copy -c:a aac "$FINAL_FILE"

    # Bersih-bersih
    rm "$VIDEO_FILE" "$AUDIO_FILE" "$PID_FILE" /tmp/toggle_recording_files

    notify-send -i "$f" "✅ Recording finished" "$FINAL_FILE"
    echo "✅ Recording finished: $FINAL_FILE"
fi
