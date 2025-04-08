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
BOLD = "\033[1m"

# Paquetes a instalar (se extraen de un archivo JSON o se definen aquí)
packages_json = '''{
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
    result = subprocess.run(f"yay -Qs {package}", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return result.returncode == 0

# Instalar paquetes AUR con yay o paru
def install_aur_packages(packages, message):
    print(f"{CYAN}{message}{RESET}")
    for package in progress_bar(packages, prefix="Instalando AUR", length=30):
        if not is_installed(package):
            print(f"{YELLOW}Instalando {package} desde AUR...{RESET}")
            if not run_command(f"yay -S --noconfirm {package}") and not run_command(f"paru -S --noconfirm {package}"):
                print(f"{RED}❌ Error instalando {package} desde AUR.{RESET}")
            else:
                print(f"{GREEN}✔️ {package} instalado correctamente.{RESET}")
        else:
            print(f"{GREEN}✔️ {package} ya está instalado.{RESET}")

# Verificar si yay o paru están instalados
def check_yay_paru():
    if not any(run_command(f"command -v {pkg}") for pkg in ["yay", "paru"]):
        print(f"{RED}❌ Ni yay ni paru están instalados. Instale uno de estos gestores de AUR.{RESET}")
        sys.exit(1)

# Función principal
def install():
    check_yay_paru()

    # Instalación de paquetes AUR
    aur_packages = packages["instalacion_aur"]
    install_aur_packages(aur_packages, "📦 Instalando paquetes AUR...")

    print(f"\n{GREEN}🎉 ¡Todas las instalaciones se completaron con éxito!{RESET}")
    print(f"{CYAN}¡Disfruta de tu sistema actualizado y personalizado!{RESET}")

