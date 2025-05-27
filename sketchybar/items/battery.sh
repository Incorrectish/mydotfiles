#!/bin/bash

battery=(
  script="$PLUGIN_DIR/battery.sh"
  icon.font="$FONT:Regular:16.0"
  padding_right=0
  padding_left=0
  label.drawing=off
  label.font="$FONT:Medium:13.0"
  label.y_offset=0
  update_freq=120
  updates=on
)

sketchybar --add item battery right      \
           --set battery "${battery[@]}" \
           --subscribe battery power_source_change system_woke
