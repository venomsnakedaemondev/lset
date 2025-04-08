#!/usr/bin/env bash

set -e
trap 'echo -e "\nError durante la ejecución. Abortando."; exit 1' ERR

# Colores ANSI
GREEN="\033[0;32m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Función spinner animado (barra de carga)
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r [%c] " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r${GREEN}✔️ Listo${RESET}\n"
}

# Función para verificar si un paquete está instalado
is_installed() {
    pacman -Q "$1" &>/dev/null
}

# Función para instalar paquetes con spinner si no están instalados
install_packages() {
    local packages="$1"
    for package in $packages; do
        if ! is_installed "$package"; then
            echo -e "${CYAN}Instalando $package...${RESET}"
            (sudo pacman -S --noconfirm "$package") & spinner
        else
            echo -e "${GREEN}$package ya está instalado. Ignorando.${RESET}"
        fi
    done
}

# Instalar yay o paru si no están instalados con spinner y borrar carpeta después
install_yay_paru() {
    if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
        echo -e "${CYAN}Instalando yay...${RESET}"
        (git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay) & spinner
    else
        echo -e "${GREEN}yay o paru ya están instalados. Ignorando.${RESET}"
    fi
}

# Actualización del sistema
echo -e "${CYAN}Actualizando el sistema...${RESET}"
(sudo pacman -Syu --noconfirm) & spinner

# Instalación de paquetes base
install_packages "python python-colorama git jq zsh"

# Instalación de yay o paru
install_yay_paru

# Instalación de paquetes AUR
if [[ -n "$json" ]]; then
    install_packages "$(echo "$json" | jq -r '.instalacion_aur | .[]' | sort -u)"
fi
