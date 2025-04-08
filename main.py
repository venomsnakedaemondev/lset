import os
import subprocess
import time
from datetime import datetime
import platform
import argparse
import logging

# Colores ANSI
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
BLUE = "\033[94m"
MAGENTA = "\033[95m"
CYAN = "\033[96m"
RESET = "\033[0m"
BOLD = "\033[1m"

# Configuración de logging
logging.basicConfig(
    filename="packager.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def banner():
    print(f"""{CYAN}{BOLD}
╔════════════════════════════════════════════╗
║                                            ║
║      🚀 Bienvenido a {YELLOW}Packager{CYAN}!                  ║
║                                            ║
╚════════════════════════════════════════════╝{RESET}
""")

def log_event(event, level="info"):
    """Registra eventos en el archivo de log"""
    if level == "info":
        logging.info(event)
    elif level == "warning":
        logging.warning(event)
    elif level == "error":
        logging.error(event)

def check_permissions():
    """Verifica que el programa se ejecute como root"""
    if os.geteuid() != 1:
        print(f"{RED}❌ Por favor, ejecuta el programa sin permisos administrativos (sudo).{RESET}")
        log_event("El programa se ejecutó con permisos administrativos.", level="error")
        exit(1)

def check_platform():
    """Verifica que el sistema operativo sea compatible"""
    os_name = platform.system()
    if os_name not in ["Linux", "Darwin"]:
        print(f"{RED}❌ Sistema operativo no compatible: {os_name}{RESET}")
        log_event(f"Sistema operativo no compatible: {os_name}", level="error")
        exit(1)

def check_files_exist():
    """Verifica que los archivos necesarios existan"""
    files = [".zshrc", ".p10k.zsh", "requirements.sh"]
    for file in files:
        if not os.path.exists(file):
            print(f"{RED}❌ Archivo no encontrado: {file}{RESET}")
            log_event(f"Archivo no encontrado: {file}", level="error")
            exit(1)

def run_command(command):
    """Ejecuta un comando en el sistema"""
    try:
        result = subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        print(f"{GREEN}✅ Comando ejecutado: {command}{RESET}")
        log_event(f"Comando ejecutado: {command}")
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"{RED}❌ Error ejecutando: {command}\n{e}{RESET}")
        log_event(f"Error ejecutando: {command} - {e}", level="error")
        exit(1)

def install_dependencies():
    """Instala las dependencias necesarias desde requirements.sh"""
    print(f"{CYAN}⏳ Instalando dependencias...{RESET}")
    try:
        check_files_exist()
        run_command("cp .zshrc ~ && cp .p10k.zsh ~")
        run_command("chmod +x requirements.sh")
        run_command("sh ./requirements.sh")
        print(f"{GREEN}✅ Todos los requisitos han sido instalados.{RESET}")
        log_event("Dependencias instaladas correctamente.")
        time.sleep(3)
    except Exception as e:
        print(f"{RED}❌ Error durante la instalación de dependencias: {e}{RESET}")
        log_event(f"Error durante la instalación de dependencias: {e}", level="error")
        exit(1)

def clear_screen():
    """Limpia la pantalla"""
    run_command("clear")

def show_loading_message(message, delay=1):
    """Muestra un mensaje de carga"""
    print(f"{MAGENTA}{message}{RESET}")
    time.sleep(delay)

def confirm_action(message):
    """Pide confirmación al usuario antes de realizar una acción"""
    response = input(f"{YELLOW}{message} (s/n): {RESET}")
    if response.lower() != "s":
        print(f"{CYAN}Operación cancelada por el usuario.{RESET}")
        log_event("Operación cancelada por el usuario.", level="warning")
        return False
    return True

def menu():
    """Muestra el menú interactivo"""
    while True:
        print(f"""{BLUE}
        [1] Instalar dependencias
        [2] Ver documentación
        [3] Salir
        {RESET}""")
        choice = input("Elige una opción: ")
        if choice == "1":
            if confirm_action("¿Estás seguro de que deseas instalar las dependencias?"):
                install_dependencies()
        elif choice == "2":
            print(f"{CYAN}📖 Aquí está la documentación...{RESET}")
            log_event("El usuario revisó la documentación.")
        elif choice == "3":
            print(f"{YELLOW}👋 Adiós!{RESET}")
            log_event("El usuario salió del programa.")
            exit(0)
        else:
            print(f"{RED}❌ Opción no válida. Intenta de nuevo.{RESET}")

def show_help():
    """Muestra la ayuda del programa"""
    print(f"""{CYAN}
    Uso: python script.py [opciones]
    Opciones:
        -h, --help     Muestra esta ayuda
        -v, --version  Muestra la versión del programa
    {RESET}""")

def start():
    """Inicia el programa"""
    check_permissions()
    check_platform()
    clear_screen()
    banner()
    print(f"{GREEN}Este programa te ayudará con tus necesidades de empaquetado.{RESET}")
    print(f"{YELLOW}Sigamos los pasos iniciales...{RESET}\n")
    if confirm_action("¿Deseas continuar con la instalación de dependencias iniciales?"):
        install_dependencies()
    show_loading_message("Cargando menú principal...")
    clear_screen()

def main():
    """Punto de entrada principal"""
    parser = argparse.ArgumentParser(description="Packager - Herramienta de empaquetado")
    parser.add_argument("-v", "--version", action="version", version="Packager 1.0")
    args = parser.parse_args()

    start()
    menu()

if __name__ == "__main__":
    main()
