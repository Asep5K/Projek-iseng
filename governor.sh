#!/bin/bash
# cpu-governor-rofi-visual.sh
# Rofi CPU governor changer dengan highlight & warna

command -v rofi >/dev/null 2>&1 || { echo "Install rofi dulu!"; exit 1; }

# Ambil daftar governor
GOVS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)
CURRENT=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

# Buat daftar untuk Rofi dengan highlight governor aktif & warna
MENU=""
for gov in $GOVS; do
    if [ "$gov" = "$CURRENT" ]; then
        MENU+=" $gov\n"   # Tanda panah untuk governor aktif
    else
        MENU+="$gov\n"
    fi
done

# Pilih governor via Rofi
SELECTED=$(echo -e "$MENU" | rofi -dmenu -p "CPU Governor:" | tr -d '\n')

# Kalau cancel
[ -z "$SELECTED" ] && exit 0

# Validasi governor
if ! echo "$GOVS" | grep -qw "$SELECTED"; then
    notify-send "CPU Governor" "Governor '$SELECTED' tidak valid!"
    exit 1
fi

# Fungsi input password
ask_password() {
    rofi -dmenu -password -p "Enter sudo password:"
}

# Fungsi validasi password
validate_password() {
    echo "$1" | sudo -S -v &>/dev/null
    return $?
}

# Minta password hingga valid
while true; do
    PASS=$(ask_password)
    if validate_password "$PASS"; then
        echo "$PASS" | sudo -S -v
        break
    else
        notify-send -t 3000 "GOVERNOR CHANGER" "Wrong password! Please try again."
    fi
done

# Ganti governor semua core
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "$SELECTED" | sudo tee "$cpu" > /dev/null
done

notify-send "CPU Governor" "Berhasil diubah ke $SELECTED"
