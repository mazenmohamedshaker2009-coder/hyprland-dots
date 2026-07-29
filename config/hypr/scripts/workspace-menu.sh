#!/bin/bash

workspace=$(hyprctl workspaces -j | jq -r '.[].id' | sort -n | rofi -dmenu -p "Workspace")

if [ -n "$workspace" ]; then
    hyprctl dispatch workspace "$workspace"
fi
