#!/bin/bash

CONFIG="$HOME/.config/niri/config.kdl"
WALL_DIR="$HOME/.config/wallpaper"
COLOR_CACHE="$HOME/.cache/wal/colors"

SEL_WALL=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)

swww img "$SEL_WALL" --transition-type wipe --transition-duration 2 --transition-fps 100

wal -i "$SEL_WALL" -n -q -s > /dev/null 2>&1

RAW_ACT=$(sed -n '3p' "$COLOR_CACHE" | tr -d '[:space:]#')
RAW_INACT=$(sed -n '1p' "$COLOR_CACHE" | tr -d '[:space:]#')

if [ -z "$RAW_ACT" ]; then
    echo "FEHLER: Pywal Cache leer."
    exit 1
fi

COLOR_ACT="#$RAW_ACT"
COLOR_INACT="#$RAW_INACT"

echo "Setze Farbe: $COLOR_ACT"

sed -i "s|active-color \".*\" // {active}|active-color \"$COLOR_ACT\" // {active}|g" "$CONFIG"
sed -i "s|inactive-color \".*\" // {inactive}|inactive-color \"$COLOR_INACT\" // {inactive}|g" "$CONFIG"

niri msg action load-config-file "$CONFIG"
