#!/bin/bash

MAIN_OPTIONS="Mount HDD\nUnmount HDD\nExit"

# Array partisi: DEV => MOUNT_POINT|LABEL
declare -A PARTITIONS=(
  ["/dev/sdb1"]="/mnt/Data|Data"
  ["/dev/sdb2"]="/mnt/Random|Random"
  ["/dev/sdb3"]="/mnt/Tools|Tools"
  ["/dev/sdb4"]="/mnt/Windows|Windows"
  ["/dev/sdb5"]="/mnt/Archbackup|Archbackup"
  ["/dev/sdb6"]="/mnt/Anime|Anime"
)

# Urutan partisi
PARTITION_ORDER=("/dev/sdb1" "/dev/sdb2" "/dev/sdb3" "/dev/sdb4" "/dev/sdb5" "/dev/sdb6")

# Fungsi cek status mount
check_status() {
    local DEV="$1"
    mountpoint -q "${PARTITIONS[$DEV]%%|*}" && echo "[mounted]" || echo "[unmounted]"
}

# Fungsi input password
ask_password() {
    rofi -dmenu -password -p "Enter sudo password:"
}

# Fungsi validasi password
validate_password() {
    echo "$1" | sudo -S -v &>/dev/null
    return $?
}

# Fungsi mount
mount_hdd() {
    PARTITION_CHOICES="All"
    for DEV in "${PARTITION_ORDER[@]}"; do
        STATUS=$(check_status "$DEV")
        PARTITION_CHOICES+=$'\n'"$DEV - ${PARTITIONS[$DEV]#*|} $STATUS"
    done
    PARTITION_CHOICES+=$'\nCancel'

    SELECTED=$(echo -e "$PARTITION_CHOICES" | rofi -dmenu -multi-select -p "Select partition(s) to mount:")
    [[ -z "$SELECTED" || "$SELECTED" =~ Cancel ]] && exit 0

    # Buat daftar DEV yang dipilih
    DEV_LIST=()
    if [[ "$SELECTED" =~ All ]]; then
        DEV_LIST=("${PARTITION_ORDER[@]}")
    else
        while IFS= read -r line; do
            DEV_LIST+=("${line%% -*}")
        done <<< "$SELECTED"
    fi

    # Minta password hingga valid
    while true; do
        PASSWORD=$(ask_password)
        if validate_password "$PASSWORD"; then
            # Aktifkan session sudo untuk beberapa menit
            echo "$PASSWORD" | sudo -S -v
            break
        else
            notify-send -t 3000 "HDD Manager" "Wrong password! Please try again."
        fi
    done

    # Mount semua partisi dengan sudo biasa (tidak pakai pipe)
    for DEV in "${DEV_LIST[@]}"; do
        sudo mount "$DEV" "${PARTITIONS[$DEV]%%|*}"
    done

    notify-send -t 3000 "HDD Manager" "Selected HDD(s) have been successfully mounted!"
}

# Fungsi unmount
unmount_hdd() {
    PARTITION_CHOICES="All"
    for DEV in "${PARTITION_ORDER[@]}"; do
        STATUS=$(check_status "$DEV")
        PARTITION_CHOICES+=$'\n'"$DEV - ${PARTITIONS[$DEV]#*|} $STATUS"
    done
    PARTITION_CHOICES+=$'\nCancel'

    SELECTED=$(echo -e "$PARTITION_CHOICES" | rofi -dmenu -multi-select -p "Select partition(s) to unmount:")
    [[ -z "$SELECTED" || "$SELECTED" =~ Cancel ]] && exit 0

    DEV_LIST=()
    if [[ "$SELECTED" =~ All ]]; then
        DEV_LIST=("${PARTITION_ORDER[@]}")
    else
        while IFS= read -r line; do
            DEV_LIST+=("${line%% -*}")
        done <<< "$SELECTED"
    fi

    while true; do
        PASSWORD=$(ask_password)
        if validate_password "$PASSWORD"; then
            echo "$PASSWORD" | sudo -S -v
            break
        else
            notify-send -t 3000 "HDD Manager" "Wrong password! Please try again."
        fi
    done

    # Unmount semua partisi dengan sudo biasa
    for DEV in "${DEV_LIST[@]}"; do
        sudo umount "${PARTITIONS[$DEV]%%|*}"
    done

    notify-send -t 3000 "HDD Manager" "Selected HDD(s) have been successfully unmounted!"
}

# Menu utama
CHOICE=$(echo -e "$MAIN_OPTIONS" | rofi -dmenu -p "Select HDD action:")

case "$CHOICE" in
    "Mount HDD")
        mount_hdd
        ;;
    "Unmount HDD")
        unmount_hdd
        ;;
    "Exit")
        exit 0
        ;;
    *)
        notify-send -t 3000 "HDD Manager" "Invalid selection!"
        ;;
esac
