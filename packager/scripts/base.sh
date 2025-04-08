#!/usr/bin/env bash

set -e

# Colores ANSI
CYAN="\033[0;36m"
GREEN="\033[0;32m"
RESET="\033[0m"

# JSON embebido
json='{
  "system_and_hardware": [
    "base", "base-devel", "lm_sensors", "mesa", "mesa-demos", "networkmanager",
    "network-manager-applet", "python", "xclip", "xorg", "xorg-server", "xorg-xinit",
    "ntp", "linux-headers", "linux-zen", "linux-zen-headers", "linux-lts", "linux-lts-headers"
  ],
  "graphics_and_window_manager": [
    "rofi", "arandr", "bspwm", "feh", "gnome", "sddm", "kitty", "pavucontrol",
    "picom", "polybar", "sxhkd", "volumeicon"
  ],
  "dev_and_system_admin": [
    "base-devel", "fastfetch", "fzf", "git", "htop", "locate", "make", "npm",
    "tree", "tmux", "unzip", "zsh", "less"
  ],
  "network_and_connectivity": [
    "firejail", "net-tools", "proxychains", "speedtest-cli", "wpa_supplicant"
  ],
  "multimedia_and_entertainment": [
    "vlc", "firefox",
    "ttf-dejavu", "ttf-dejavu-nerd", "ttf-fantasque-nerd", "ttf-fantasque-sans-mono",
    "ttf-fira-code", "ttf-fira-mono", "ttf-hack", "ttf-hack-nerd", "ttf-iosevka-nerd",
    "ttf-jetbrains-mono", "ttf-jetbrains-mono-nerd", "ttf-liberation", "ttf-liberation-mono-nerd",
    "ttf-nerd-fonts-symbols", "ttf-terminus-nerd"
  ],
  "productivity": [
    "jq", "lsd", "numlockx", "ranger", "wget", "curl", "zoxide"
  ],
  "miscellaneous": [
    "bat", "qt6-svg", "qt5-quickcontrols2", "qt6-declarative",
    "neofetch", "btop", "libxcb", "opendesktop-fonts", "xcb-util",
    "xcb-util-keysyms", "xcb-util-wm"
  ],
  "agregados": []
}'

# Función spinner animado
loading_bar() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    printf "${CYAN}🔄 Instalando paquetes... "
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf " ${GREEN}✔️ Hecho${RESET}\n"
}

# Verifica que jq esté instalado
if ! command -v jq &> /dev/null; then
    echo -e "${CYAN}📦 Instalando jq...${RESET}"
    sudo pacman -S jq --noconfirm
fi

# Extraer paquetes únicos
all_packages=$(echo "$json" | jq -r '.[] | .[]' | sort -u)

# Instalar paquetes con barra animada
(sudo pacman -S --noconfirm $all_packages) & loading_bar

echo -e "${GREEN}🎉 Todos los paquetes han sido instalados correctamente.${RESET}"
