#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

BATTERY_INFO="$(pmset -g batt)"
PERCENTAGE=$(echo "$BATTERY_INFO" | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(echo "$BATTERY_INFO" | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

if [[ $CHARGING != "" ]]; then
  case ${PERCENTAGE} in
    9[0-9]|100) ICON="󰂅"
    ;;
    [6-8][0-9]) ICON="󰢞"
    ;;
    [3-5][0-9]) ICON="󰢝"
    ;;
    [1-2][0-9]) ICON="󰂇" COLOR=$RED
    ;;
    *) ICON="󰢜"; COLOR=$RED
    esac
else
    case ${PERCENTAGE} in
        9[0-9]|100) ICON="󰁹"
        ;;
        [6-8][0-9]) ICON="󰂀"
        ;;
        [3-5][0-9]) ICON="󰁾"
        ;;
        [1-2][0-9]) ICON="󰁼" COLOR=$RED
        ;;
        *) ICON="󰁺"; COLOR=$RED
    esac
fi

#if [[ $CHARGING != "" ]]; then
  #case ${PERCENTAGE} in
    #9[0-9]|100) ICON="󰂅"
    #;;
    #[6-8][0-9]) ICON="󰢞"
    #;;
    #[3-5][0-9]) ICON="󰢝"
    #;;
    #[1-2][0-9]) ICON="󰂇" COLOR=$RED
    #;;
    #*) ICON="󰢜"; COLOR=$RED
    #esac
#else
    #case ${PERCENTAGE} in
        #9[0-9]|100) ICON="󰁹"
        #;;
        #[6-8][0-9]) ICON="󰂀"
        #;;
        #[3-5][0-9]) ICON="󰁾"
        #;;
        #[1-2][0-9]) ICON="󰁼" COLOR=$RED
        #;;
        #*) ICON="󰁺"; COLOR=$RED
    #esac
#fi
sketchybar --set $NAME icon="$ICON" label="$ICON ${PERCENTAGE}%" label.color=$WHITE label.drawing=on icon.color=$COLOR

