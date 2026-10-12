#!/bin/bash
MUSIC_DIR="/mnt/space/music"
FILE=$(echo "$SELECTED_SONGS" | head -n1)
[ -z "$FILE" ] && FILE="$CURRENT_SONG"
DIR=$(dirname "$MUSIC_DIR/$FILE")
picard "$DIR" &
disown
