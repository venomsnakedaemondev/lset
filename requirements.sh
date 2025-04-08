#!/usr/bin/env bash

set -e
trap 'echo -e "\nError durante la ejecución. Abortando."; exit 1' ERR

# Colores ANSI
GREEN="\033[0;32m"
CYAN="\033[0;36m"
RESET="\033[0m"
BAR_LENGTH=50  # Longitud de la barra de progreso

# Función para imprimir la barra de progreso
print_progress() {
    local progress=$1
    local max=$2
    local length=$3
    local percent=$(( progress * 100 / max ))
    local completed=$(( progress * length / max ))
    local remaining=$(( length - completed ))

    # Crear la barra de progreso
    printf "\r${CYAN}[" 
    for ((i=0; i<completed; i++)); do
        printf "="
    done
    for ((i=0; i<remaining; i++)); do
        printf " "
    done
    printf "] %3d%%${RESET}" $percent
}

# Función para la barra de carga general
general_spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\\'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        # Limpia la pantalla y muestra el spinner y la barra de carga general
        clear
        printf "${CYAN}Instalando... [%c]${RESET}\n" "$spinstr"
        print_progress $progress $total $BAR_LENGTH
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    clear
    printf "${GREEN}✔️ Listo${RESET}\n"
}

# Función para la barra de carga individual
individual_spinner() {
    local package=$1
    local pid=$2
    local progress=0
    local total=100
    while kill -0 $pid 2>/dev/null; do
        ((progress++))
        print_progress $progress $total $BAR_LENGTH
        sleep 0.05
    done
    echo -e "\n${GREEN}✔️ Instalado $package${RESET}"
}

# Función para verificar si un paquete está instalado
is_installed() {
    pacman -Q "$1" &>/dev/null
}

# Función para instalar paquetes con barra de carga individual
install_packages() {
    local packages="$1"
    for package in $packages; do
        if ! is_installed "$package"; then
            echo -e "${CYAN}Instalando $package...${RESET}"
            (sudo pacman -S --noconfirm "$package" && sleep 2) & individual_spinner "$package" $!
        else
            echo -e "${GREEN}$package ya está instalado. Ignorando.${RESET}"
        fi
    done
}

# Función para instalar yay o paru si no están instalados con barra de carga
install_yay_paru() {
    if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
        echo -e "${CYAN}Instalando yay...${RESET}"
        (git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay) & individual_spinner "yay" $!
    else
        echo -e "${GREEN}yay o paru ya están instalados. Ignorando.${RESET}"
    fi
}

# Función para verificar si jq está instalado
check_jq_installed() {
    if ! command -v jq &>/dev/null; then
        echo -e "${RED}❌ jq no está instalado. Instalando jq...${RESET}"
        sudo pacman -S --noconfirm jq
    fi
}

# Función para verificar si git está instalado
check_git_installed() {
    if ! command -v git &>/dev/null; then
        echo -e "${RED}❌ git no está instalado. Instalando git...${RESET}"
        sudo pacman -S --noconfirm git
    fi
}

# Actualización del sistema
echo -e "${CYAN}Actualizando el sistema...${RESET}"
(sudo pacman -Syu --noconfirm) & general_spinner

# Instalación de paquetes base
install_packages "python python-colorama git jq zsh"

# Verificar y instalar yay/paru si es necesario
install_yay_paru

# Verificar si jq está instalado antes de procesar el JSON
check_jq_installed

# Instalación de paquetes AUR desde JSON
if [[ -n "$json" ]]; then
    install_packages "$(echo "$json" | jq -r '.instalacion_aur | .[]' | sort -u)"
fi
