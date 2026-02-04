#!/bin/bash

CONFIG="$HOME/.config/niri/conf/layout.kdl"
WALL_DIR="$HOME/.config/wallpaper"
COLOR_CACHE="$HOME/.cache/wal/colors"
SPICE_THEME="$HOME/.config/spicetify/Themes/wal"
OBSIDIAN_VAULT="$HOME/Documents/obsidian-vault"

TMP_FILE=$(mktemp)
ranger --choosefile="$TMP_FILE" "$WALL_DIR"
SELECTED=$(cat "$TMP_FILE")
rm "$TMP_FILE"

[ -z "$SELECTED" ] && exit 0

swww img "$SELECTED" --transition-type wipe --transition-duration 2 --transition-fps 100

wal -i "$SELECTED" -n -q

cp "$HOME/.cache/wal/spicetify" "$SPICE_THEME/color.ini"

touch "$HOME/.config/vesktop/themes/pywal.theme.css"

pywalfox update

mkdir -p "$OBSIDIAN_VAULT/.obsidian/snippets/"
cp "$HOME/.cache/wal/colors.css" "$OBSIDIAN_VAULT/.obsidian/snippets/wal-colors.css"

RAW_ACT=$(sed -n '3p' "$COLOR_CACHE" | tr -d '[:space:]#')
RAW_INACT=$(sed -n '1p' "$COLOR_CACHE" | tr -d '[:space:]#')

if [ -n "$RAW_ACT" ]; then
    COLOR_ACT="#$RAW_ACT"
    COLOR_INACT="#$RAW_INACT"
    
    sed -i "s|active-color \".*\" // {active}|active-color \"$COLOR_ACT\" // {active}|g" "$CONFIG"
    sed -i "s|inactive-color \".*\" // {inactive}|inactive-color \"$COLOR_INACT\" // {inactive}|g" "$CONFIG"
    
    niri msg action load-config-file "$CONFIG"
fi