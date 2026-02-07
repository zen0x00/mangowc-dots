#!/bin/bash

install_aur_packages() {
    local packages=(
        ani-cli
        awww-git
        bc
        bluetui
        brightnessctl
        cliphist
        discord
        fastfetch
        ffmpeg
        fzf
        gamemode
        gtk-engine-murrine
        grim
        idescriptor-git
        imagemagick
        impala
        jq
        kitty
        lazygit
        lib32-gamemode
        localsend
        mangohud
        mangowc-git
        neovim
        notify-send
        noto-fonts
        nwg-look
        obs-pipewire-audio-capture
        obs-studio
        obs-vkcapture
        openrgb
        quickshell
        rofi-wayland
        satty
        sddm
        sddm-silent-theme
        slurp
        sox
        spicetify-cli
        spotify
        sway-audio-idle-inhibit-git
        swaybg
        swayidle
        swaylock
        swaync
        swayosd
        sunset-cursors-git
        starship
        stow
        treesitter-cli
        ttf-gohu-nerd
        ttf-ibm-plex
        ttf-jetbrains-mono-nerd
        ttf-roboto
        ttf-twemoji
        waybar
        wl-clip-persist
        wl-clipboard
        wlogout
        wlr-dpms
        wlr-randr
        wlsunset
        wiremix
        xdg-desktop-portal-wlr
        yad
        zen-browser-bin
        zoxide
    )

    local to_install=()
    for pkg in "${packages[@]}"; do
        if pacman -Qi "$pkg" >/dev/null 2>&1; then
            info "$pkg already installed — skipping."
        else
            to_install+=("$pkg")
        fi
    done

    if (( ${#to_install[@]} > 0 )); then
        yay -S --noconfirm "${to_install[@]}"
    fi
}
