#!/usr/bin/env bash

set -e  # Salir si ocurre un error
trap 'echo -e "\n${RED}❌ Error durante la ejecución. Abortando.${RESET}"; exit 1' ERR

# Colores ANSI
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
RESET="\033[0m"

# Spinner animado
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

# 🔄 Actualización del sistema
echo -e "${CYAN}🔄 Actualizando el sistema...${RESET}"
(sudo pacman -Syu --noconfirm) & spinner

# 📦 Instalación de paquetes base
echo -e "${YELLOW}📦 Instalando paquetes base...${RESET}"
sleep 1
(sudo pacman -S python python-colorama git jq zsh --noconfirm) & spinner

# 🧰 Comprobar si yay y paru están instalados
if ! command -v yay &>/dev/null; then
    echo -e "${CYAN}⬇ Instalando yay...${RESET}"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
    echo -e "${GREEN}🎉 Yay ha sido instalado correctamente.${RESET}"
else
    echo -e "${GREEN}🎉 Yay ya está instalado.${RESET}"
fi

if ! command -v paru &>/dev/null; then
    echo -e "${CYAN}⬇ Instalando paru...${RESET}"
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
    echo -e "${GREEN}🎉 Paru ha sido instalado correctamente.${RESET}"
else
    echo -e "${GREEN}🎉 Paru ya está instalado.${RESET}"
fi
# 🛠️ Instalación de paquetes adicionales