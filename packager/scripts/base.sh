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
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r ${CYAN}🔄 Instalando... [%c]${RESET} " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r ${GREEN}✔️ Instalación completada${RESET}\n"
}

# Verificar si un paquete está instalado
is_installed() {
    pacman -Q "$1" &> /dev/null
}

# Verifica que jq esté instalado
if ! is_installed jq; then
    echo -e "${CYAN}Instalando jq...${RESET}"
    (sudo pacman -S jq --noconfirm) & loading_bar
fi

# Extraer paquetes únicos
all_packages=$(echo "$json" | jq -r '.[] | .[]' | sort -u)

# Instalar paquetes no instalados con barra animada
for package in $all_packages; do
    if ! is_installed "$package"; then
        echo -e "${CYAN}Instalando $package...${RESET}"
        (sudo pacman -S --noconfirm "$package") & loading_bar
    else
        echo -e "${GREEN}$package ya está instalado. Ignorando.${RESET}"
    fi
done
