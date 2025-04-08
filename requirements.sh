#!/usr/bin/env bash

set -e
trap 'echo -e "\n${RED}❌ Error durante la ejecución. Abortando.${RESET}"; exit 1' ERR

# Colores ANSI
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
RESET="\033[0m"

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

# Instalar yay o paru si no están instalados
install_yay_paru() {
    if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
        echo -e "${CYAN}⬇ Instalando yay...${RESET}"
        (git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay) & spinner
        echo -e "${GREEN}🎉 Yay ha sido instalado correctamente.${RESET}"
    fi
}

# Actualización del sistema
echo -e "${CYAN}🔄 Actualizando el sistema...${RESET}"
(sudo pacman -Syu --noconfirm) & spinner

# Instalación de paquetes base
install_packages "python python-colorama git jq zsh" "📦 Instalando paquetes base..."

# Instalar yay o paru
install_yay_paru

# Instalación de paquetes AUR
install_aur_packages "$(echo "$json" | jq -r '.instalacion_aur | .[]' | sort -u)" "📦 Instalando paquetes AUR..."

# Finalización
echo -e "${GREEN}🎉 ¡Todas las instalaciones se completaron con éxito!${RESET}"
