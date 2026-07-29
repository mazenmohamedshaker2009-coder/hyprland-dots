#!/bin/bash

DIR="$HOME/Screenshots"
mkdir -p "$DIR"

FILE="$DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"

grim "$FILE"

notify-send "Screenshot" "Saved to $FILE"
