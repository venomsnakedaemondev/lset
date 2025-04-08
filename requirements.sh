#!/usr/bin/env bash

set -e
trap 'echo -e "\n${RED}❌ Error durante la ejecución. Abortando.${RESET}"; exit 1' ERR

# Colores ANSI
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
RESET="\033[0m"

# JSON embebido con paquetes
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
  "instalacion_aur": [
    "p7zip-gui",
    "scrub",
    "otf-material-design-icons",
    "ttf-material-design-icons-desktop-git",
    "ttf-material-design-iconic-font",
    "otf-material-design-icons",
    "ttf-font-awesome",
    "freetube",
    "powerline-fonts",
    "ttf-weather-icons",
    "ttf-devicons",
    "vscode-codicons-git",
    "ttf-font-logos",
    "ttf-pomicons",
    "ttf-meslo-nerd-font-powerlevel10k",
    "ttf-meslo-nerd",
    "adobe-source-code-pro-fonts",
    "catppuccin-cursors-latte",
    "catppuccin-cursors-frappe",
    "catppuccin-cursors-macchiato",
    "catppuccin-cursors-mocha",
    "visual-studio-code-bin",
    "brave-bin",
    "github-desktop-bin"
  ]
}'

# Función spinner animado
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\' 
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf " ${GREEN}✔️ Listo${RESET}\n"
}

# Función para instalar paquetes con spinner
install_packages() {
    local packages="$1"
    local message="$2"
    echo -e "${CYAN}${message}${RESET}"
    (sudo pacman -S --noconfirm $packages) & spinner
}

# Función para instalar paquetes desde AUR con yay o paru
install_aur_packages() {
    local packages="$1"
    local message="$2"
    echo -e "${CYAN}${message}${RESET}"

    if command -v yay &>/dev/null; then
        (yay -S --noconfirm $packages) & spinner
    elif command -v paru &>/dev/null; then
        (paru -S --noconfirm $packages) & spinner
    else
        echo -e "${RED}❌ Ni yay ni paru están instalados. No se pueden instalar los paquetes AUR.${RESET}"
        exit 1
    fi
}

# 🔄 Actualización del sistema
echo -e "${CYAN}🔄 Actualizando el sistema...${RESET}"
(sudo pacman -Syu --noconfirm) & spinner

# 📦 Instalación de paquetes base
install_packages "python python-colorama git jq zsh" "📦 Instalando paquetes base..."

# 🧰 Comprobar si yay y paru están instalados
if ! command -v yay &>/dev/null; then
    echo -e "${CYAN}⬇ Instalando yay...${RESET}"
    (git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay) & spinner
    echo -e "${GREEN}🎉 Yay ha sido instalado correctamente.${RESET}"
else
    echo -e "${GREEN}🎉 Yay ya está instalado.${RESET}"
fi

if ! command -v paru &>/dev/null; then
    echo -e "${CYAN}⬇ Instalando paru...${RESET}"
    (git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm && cd .. && rm -rf paru) & spinner
    echo -e "${GREEN}🎉 Paru ha sido instalado correctamente.${RESET}"
else
    echo -e "${GREEN}🎉 Paru ya está instalado.${RESET}"
fi

# 🛠️ Instalar paquetes del JSON
echo -e "${YELLOW}📦 Instalando paquetes del sistema...${RESET}"
all_packages=$(echo "$json" | jq -r '.[] | .[]' | sort -u)
install_packages "$all_packages" "📦 Instalando paquetes del JSON..."

# 📦 Instalación de paquetes AUR
install_aur_packages "$(echo "$json" | jq -r '.instalacion_aur | .[]' | sort -u)" "📦 Instalando paquetes AUR..."

# 🖥️ Instalar Oh My Zsh
echo -e "${CYAN}🖥️ Instalando Oh My Zsh...${RESET}"
(sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "") & spinner

echo -e "${GREEN}🎉 ¡Todas las instalaciones se completaron con éxito!${RESET}"
