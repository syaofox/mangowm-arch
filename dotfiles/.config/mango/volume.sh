#!/bin/bash

mode="$1"

get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | head -n1 | awk '{print $5}' | sed 's/%//'
}

case "$mode" in
    up)
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        vol=$(get_volume)
        notify-send -r 9988 -t 500 -h int:value:${vol} -h string:x-canonical-private-synchronous:volume "Volume"
        ;;
    down)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        vol=$(get_volume)
        notify-send -r 9988 -t 500 -h int:value:${vol} -h string:x-canonical-private-synchronous:volume "Volume"
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        if pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes; then
            notify-send -r 9988 -t 1000 -h string:x-canonical-private-synchronous:volume "Muted"
        else
            vol=$(get_volume)
            notify-send -r 9988 -t 500 -h int:value:${vol} -h string:x-canonical-private-synchronous:volume "Volume"
        fi
        ;;
esac