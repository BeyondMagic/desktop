#!/usr/bin/env bash

# Path to your shader file
SHADER_PATH="$HOME/.config/hypr/shaders/match_color.frag"

# Check current shader status
CURRENT=$(hyprctl -j getoption decoration:screen_shader | jq -r '.str')

if [[ "$CURRENT" == "$SHADER_PATH" ]]; then
    # If active, turn it off
    hyprctl keyword decoration:screen_shader "[[EMPTY]]"
else
    # If inactive, turn it on
    hyprctl keyword decoration:screen_shader "$SHADER_PATH"
fi
