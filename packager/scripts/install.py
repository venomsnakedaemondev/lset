import os
import subprocess
import sys
import json
import time

# Colores para imprimir
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
CYAN = "\033[0;36m"
RED = "\033[0;31m"
RESET = "\033[0m"

# Paquetes a instalar (se extraen de un archivo JSON o se definen aquí)
packages_json = '''{
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
}'''

# Convertir el JSON a un diccionario de Python
packages = json.loads(packages_json)

# Función para ejecutar comandos y comprobar el resultado
def run_command(command):
    try:
        result = subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return result.returncode == 0
    except subprocess.CalledProcessError as e:
        print(f"{RED}Error ejecutando: {e.cmd}{RESET}")
        return False

# Función de barra de progreso
def progress_bar(iterable, prefix='', length=50, fill='█'):
    total = len(iterable)
    for i, item in enumerate(iterable, 1):
        percent = (i / total) * 100
        filled_length = int(length * i // total)
        bar = fill * filled_length + '-' * (length - filled_length)
        print(f'\r{prefix} |{bar}| {percent:.2f}% Complete', end='\r')
        yield item
        time.sleep(0.1)
    print()

# Comprobar si un paquete está instalado
def is_installed(package):
    result = subprocess.run(f"pacman -Qs {package}", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return result.returncode == 0

# Instalar paquetes
def install_packages(packages, message):
    print(f"{CYAN}{message}{RESET}")
    for package in progress_bar(packages, prefix="Instalando paquetes", length=30):
        if not is_installed(package):
            print(f"{YELLOW}Instalando {package}...{RESET}")
            if not run_command(f"sudo pacman -S --noconfirm {package}"):
                print(f"{RED}❌ Error instalando {package}.{RESET}")
        else:
            print(f"{GREEN}{package} ya está instalado.{RESET}")

# Instalar paquetes AUR con yay o paru
def install_aur_packages(packages, message):
    print(f"{CYAN}{message}{RESET}")
    for package in progress_bar(packages, prefix="Instalando AUR", length=30):
        if not is_installed(package):
            print(f"{YELLOW}Instalando {package} desde AUR...{RESET}")
            if not run_command(f"yay -S --noconfirm {package}") and not run_command(f"paru -S --noconfirm {package}"):
                print(f"{RED}❌ Error instalando {package} desde AUR.{RESET}")
        else:
            print(f"{GREEN}{package} ya está instalado.{RESET}")

# Verificar si yay o paru están instalados
def check_yay_paru():
    if not any(run_command(f"command -v {pkg}") for pkg in ["yay", "paru"]):
        print(f"{RED}❌ Ni yay ni paru están instalados. Instale uno de estos gestores de AUR.{RESET}")
        sys.exit(1)

# Función principal
def install():
    check_yay_paru()

    # Actualización del sistema
    print(f"{CYAN}🔄 Actualizando el sistema...{RESET}")
    run_command("sudo pacman -Syu --noconfirm")

    # Instalación de paquetes base
    base_packages = ["python", "python-colorama", "git", "jq", "zsh"]
    install_packages(base_packages, "📦 Instalando paquetes base...")

    # Instalación de paquetes AUR
    aur_packages = packages["instalacion_aur"]
    install_aur_packages(aur_packages, "📦 Instalando paquetes AUR...")

    print(f"{GREEN}🎉 ¡Todas las instalaciones se completaron con éxito!{RESET}")
