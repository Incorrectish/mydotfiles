#!/bin/bash

source "$CONFIG_DIR/colors.sh" # Loads all defined colors
FRONT_APP_SCRIPT='[ "$SENDER" = "front_app_switched" ] && sketchybar --set $NAME label="$INFO"'

front_app=(
  icon.drawing=off
  label.font="$FONT:Black:12.0"
  associated_display=active
  script="$FRONT_APP_SCRIPT"
  background.color=$BACKGROUND_1



)

sketchybar --add item front_app left         \
           --set front_app "${front_app[@]}" \
           --subscribe front_app front_app_switched
