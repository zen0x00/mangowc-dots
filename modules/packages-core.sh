#!/bin/bash

install_core_packages() {

    local packages=(
        # --- Original core packages ---
        bluez
        bluez-utils
        efibootmgr
        gnome-keyring
        lib32-vulkan-icd-loader
        libsecret
        ntfs-3g
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts-extra
        os-prober
        seahorse
        uwsm
        vulkan-icd-loader

        # --- Added System Utilities ---
        brightnessctl
        cliphist
        gvfs
        gvfs-mtp
        network-manager-applet
        networkmanager
        pavucontrol
        playerctl
        wl-clipboard

        # --- Added Appearance / QT / Theming ---
        lxappearance
        qt5-base
        qt5-wayland
        qt5ct
        qt6-base
        qt6-wayland
        sassc

        # --- Networking / Connectivity ---
        curl
        openssh
        rsync
        ufw
        wget

        # --- Archive / Compression Tools ---
        gzip
        p7zip
        tar
        unzip
        zip

        # --- System Cleaning Tools ---
        bleachbit
        duf
        dust
        ncdu

        # --- Workflow Tools ---
        bat
        btop
        fd
        ripgrep
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
