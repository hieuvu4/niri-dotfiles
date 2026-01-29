#!/bin/bash

# Pfade definieren
CONFIG="$HOME/.config/niri/config.kdl"
WALL_DIR="$HOME/.config/wallpaper"
COLOR_CACHE="$HOME/.cache/wal/colors"

# 1. Ranger Auswahl
TMP_FILE=$(mktemp)
ranger --choosefile="$TMP_FILE" "$WALL_DIR"
SELECTED=$(cat "$TMP_FILE")
rm "$TMP_FILE"

# Abbrechen wenn leer
[ -z "$SELECTED" ] && exit 0

# 2. Wallpaper setzen
swww img "$SELECTED" --transition-type wipe --transition-duration 2 --transition-fps 100

# 3. Pywal Farben generieren
wal -i "$SELECTED" -n -q -s

# 4. Farben aus Pywal Cache extrahieren (Zeile 3 für Aktiv, Zeile 1 für Inaktiv)
RAW_ACT=$(sed -n '3p' "$COLOR_CACHE" | tr -d '[:space:]#')
RAW_INACT=$(sed -n '1p' "$COLOR_CACHE" | tr -d '[:space:]#')

# 5. In Niri Config schreiben und live laden
if [ -n "$RAW_ACT" ]; then
    COLOR_ACT="#$RAW_ACT"
    COLOR_INACT="#$RAW_INACT"
    
    # Hier passiert die Magie: sed sucht nach dem // {active} Kommentar
    sed -i "s|active-color \".*\" // {active}|active-color \"$COLOR_ACT\" // {active}|g" "$CONFIG"
    sed -i "s|inactive-color \".*\" // {inactive}|inactive-color \"$COLOR_INACT\" // {inactive}|g" "$CONFIG"
    
    # Niri anweisen, die Config neu zu lesen
    niri msg action load-config-file "$CONFIG"
fi