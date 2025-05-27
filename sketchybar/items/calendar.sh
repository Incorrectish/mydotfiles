#!/bin/bash

calendar=(
  icon=cal
  icon.font="$FONT:Black:12.0"
  icon.padding_right=0
  label.width=0
  label.align=center
  padding_left=0
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
  click_script="$PLUGIN_DIR/zen.sh"
  background.color=$BACKGROUND_1
    background.border_color=$BACKGROUND_2
    background.padding_left=10
icon.padding_left=10
icon.padding_right=10
)

sketchybar --add item calendar right       \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
