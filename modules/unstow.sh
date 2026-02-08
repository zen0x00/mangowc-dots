#!/bin/bash

run_unstow() {
    local CONFIG_DIR="$HOME/.config"
    local folders=(waybar kitty fastfetch rofi gtk-3.0 gtk-4.0 swaylock swaync swayosd wlogout mango)

    for folder in "${folders[@]}"; do
        local target="$CONFIG_DIR/$folder"
        stow --delete --target="$target" "$folder"
    done

    stow --delete --target="$CONFIG_DIR" starship
    stow --delete --target="$HOME/Pictures" Pictures
}

run_unstow
