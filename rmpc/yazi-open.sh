#!/bin/bash
# rmpc passes song paths relative to the MPD music directory
MUSIC_DIR="/mnt/space/music/"
SONG_PATH="$SELECTED_SONGS"

# Only take the first line in case multiple are selected
FILE=$(echo "$SONG_PATH" | head -n1)

# Get the folder containing the track
DIR=$(dirname "$MUSIC_DIR/$FILE")

foot -e yazi "$DIR"
