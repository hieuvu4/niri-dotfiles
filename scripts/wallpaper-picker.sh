#!/bin/bash

# Pfade
CONFIG="$HOME/.config/niri/config.kdl"
WALL_DIR="$HOME/.config/wallpaper"
COLOR_CACHE="$HOME/.cache/wal/colors"
SPICE_THEME="$HOME/.config/spicetify/Themes/wal"

# 1. Bild mit Ranger aussuchen
TMP_FILE=$(mktemp)
ranger --choosefile="$TMP_FILE" "$WALL_DIR"
SELECTED=$(cat "$TMP_FILE")
rm "$TMP_FILE"

[ -z "$SELECTED" ] && exit 0

# 2. Wallpaper setzen mit swww
swww img "$SELECTED" --transition-type wipe --transition-duration 2 --transition-fps 100

# 3. Pywal Farben extrahieren
# -q für quiet, -n für kein Setzen des Xresources (da wir Niri/Wayland nutzen)
wal -i "$SELECTED" -n -q

# 4. Themes aktualisieren
# Spicetify: Watcher im Hintergrund erkennt die Änderung an color.ini sofort
cp "$HOME/.cache/wal/spicetify" "$SPICE_THEME/color.ini"

# Vesktop: Datei berühren, damit der CSS-Import neu geladen wird
touch "$HOME/.config/vesktop/themes/pywal.theme.css"

# Browser (Firefox via Pywalfox)
pywalfox update

# 5. Niri Farben extrahieren (Zeile 3 Aktiv, Zeile 1 Inaktiv)
RAW_ACT=$(sed -n '3p' "$COLOR_CACHE" | tr -d '[:space:]#')
RAW_INACT=$(sed -n '1p' "$COLOR_CACHE" | tr -d '[:space:]#')

# 6. In Niri Config schreiben
if [ -n "$RAW_ACT" ]; then
    COLOR_ACT="#$RAW_ACT"
    COLOR_INACT="#$RAW_INACT"
    
    sed -i "s|active-color \".*\" // {active}|active-color \"$COLOR_ACT\" // {active}|g" "$CONFIG"
    sed -i "s|inactive-color \".*\" // {inactive}|inactive-color \"$COLOR_INACT\" // {inactive}|g" "$CONFIG"
    
    niri msg action load-config-file "$CONFIG"
fi