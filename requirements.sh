#!/usr/bin/env bash

set -e
trap 'echo -e "\nError durante la ejecución. Abortando."; exit 1' ERR

# Colores ANSI mejorados
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RED="\033[1;31m"
RESET="\033[0m"

# Configuración de la barra de progreso
BAR_LENGTH=40
SPINNER_STATES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

# Variables globales para el progreso
TOTAL_STEPS=0
CURRENT_STEP=0

# Función para inicializar el progreso
init_progress() {
    TOTAL_STEPS=$1
    CURRENT_STEP=0
}

# Función para actualizar el progreso
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
}

# Función para mostrar una barra de progreso animada
show_progress_bar() {
    local current=$1
    local total=$2
    local message=${3:-"Progreso"}
    local bar_length=${4:-$BAR_LENGTH}
    
    local percent=$((current * 100 / total))
    local progress=$((current * bar_length / total))
    local remaining=$((bar_length - progress))
    
    # Color del porcentaje
    local color=$GREEN
    if [ $percent -lt 30 ]; then
        color=$RED
    elif [ $percent -lt 70 ]; then
        color=$YELLOW
    fi
    
    # Barra de progreso con colores
    printf "\r${BLUE}${message}:${RESET} ["
    for ((i=0; i<progress; i++)); do
        printf "${color}=${RESET}"
    done
    for ((i=0; i<remaining; i++)); do
        printf " "
    done
    printf "] ${color}%3d%%${RESET}" $percent
}

# Función para mostrar un spinner animado
show_spinner() {
    local pid=$!
    local message=${1:-"Procesando"}
    local delay=0.1
    local spin_idx=0
    
    while kill -0 $pid 2>/dev/null; do
        spin_idx=$(( (spin_idx + 1) % ${#SPINNER_STATES[@]} ))
        printf "\r${CYAN}${SPINNER_STATES[$spin_idx]}${RESET} ${BLUE}${message}...${RESET}"
        sleep $delay
    done
    
    printf "\r${GREEN}✓${RESET} ${BLUE}${message} completado.${RESET}%20s\n"
}

# Función para mostrar progreso combinado (spinner + barra)
show_combined_progress() {
    local pid=$!
    local message=${1:-"Instalando"}
    local delay=0.1
    local spin_idx=0
    local progress=0
    
    while kill -0 $pid 2>/dev/null; do
        spin_idx=$(( (spin_idx + 1) % ${#SPINNER_STATES[@]} ))
        progress=$(( (progress + 1) % 100 ))
        
        # Mostrar spinner y barra de progreso
        printf "\r${CYAN}${SPINNER_STATES[$spin_idx]}${RESET} ${BLUE}${message}${RESET} "
        show_progress_bar $progress 100 "" 30
        sleep $delay
    done
    
    # Mostrar resultado final
    printf "\r${GREEN}✓${RESET} ${BLUE}${message} completado.${RESET}%30s\n"
}

# Función para verificar si un paquete está instalado
is_installed() {
    pacman -Q "$1" &>/dev/null
}

# Función para instalar paquetes con progreso visual
install_packages() {
    local packages="$1"
    local total=$(echo "$packages" | wc -w)
    local count=0
    
    init_progress $total
    
    for package in $packages; do
        update_progress
        if ! is_installed "$package"; then
            echo -e "${BLUE}Instalando paquete ${CYAN}${package}${BLUE} (${count}/${total})...${RESET}"
            (sudo pacman -S --noconfirm "$package" > /dev/null 2>&1) & show_combined_progress "Instalando $package"
            echo -e "${GREEN}✔ ${package} instalado correctamente.${RESET}\n"
        else
            echo -e "${YELLOW}➤ ${package} ya está instalado. Omintiendo.${RESET}\n"
        fi
        count=$((count + 1))
    done
}

# Función para instalar yay o paru con progreso visual
install_yay_paru() {
    if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
        echo -e "${BLUE}Instalando yay (AUR helper)...${RESET}"
        (git clone https://aur.archlinux.org/yay.git > /dev/null 2>&1 && \
         cd yay && \
         makepkg -si --noconfirm > /dev/null 2>&1 && \
         cd .. && \
         rm -rf yay) & show_combined_progress "Instalando yay"
        echo -e "${GREEN}✔ yay instalado correctamente.${RESET}\n"
    else
        echo -e "${YELLOW}➤ yay o paru ya están instalados. Omintiendo.${RESET}\n"
    fi
}

# Función para verificar dependencias
check_dependencies() {
    local dependencies=("git" "jq")
    
    for dep in "${dependencies[@]}"; do
        if ! command -v $dep &>/dev/null; then
            echo -e "${RED}❌ ${dep} no está instalado. Instalando...${RESET}"
            (sudo pacman -S --noconfirm $dep > /dev/null 2>&1) & show_combined_progress "Instalando $dep"
            echo -e "${GREEN}✔ ${dep} instalado correctamente.${RESET}\n"
        fi
    done
}

# Mostrar banner de inicio
echo -e "${CYAN}==========================================${RESET}"
echo -e "${GREEN} Script de Instalación para Arch Linux ${RESET}"
echo -e "${CYAN}==========================================${RESET}\n"

# Actualización del sistema con progreso
echo -e "${BLUE}Actualizando el sistema...${RESET}"
(sudo pacman -Syu --noconfirm > /dev/null 2>&1) & show_combined_progress "Actualizando sistema"
echo -e "${GREEN}✔ Sistema actualizado correctamente.${RESET}\n"

# Instalación de paquetes base
BASE_PACKAGES="python python-colorama git jq zsh"
echo -e "${BLUE}Instalando paquetes base...${RESET}"
install_packages "$BASE_PACKAGES"

# Verificar e instalar dependencias
check_dependencies

# Verificar y instalar yay/paru si es necesario
install_yay_paru

# Instalación de paquetes AUR desde JSON (si existe)
if [[ -n "$json" ]]; then
    AUR_PACKAGES=$(echo "$json" | jq -r '.instalacion_aur | .[]' | sort -u)
    echo -e "${BLUE}Instalando paquetes AUR...${RESET}"
    install_packages "$AUR_PACKAGES"
fi

# Mensaje de finalización
echo -e "\n${GREEN}==========================================${RESET}"
echo -e "${GREEN} ¡Instalación completada con éxito! ${RESET}"
echo -e "${GREEN}==========================================${RESET}\n"