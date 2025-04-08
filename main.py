from packager.menu import menu
from os import system
import time

# Colores ANSI
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
BLUE = "\033[94m"
MAGENTA = "\033[95m"
CYAN = "\033[96m"
RESET = "\033[0m"
BOLD = "\033[1m"

def banner():
    print(f"""{CYAN}{BOLD}
╔════════════════════════════════════════════╗
║                                            ║
║      🚀 Bienvenido a {YELLOW}Packager{CYAN}!                  ║
║                                            ║
╚════════════════════════════════════════════╝{RESET}
""")

def install_dependencies():
    """Instala las dependencias necesarias desde requirements.sh"""
    print(f"{CYAN}⏳ Instalando dependencias...{RESET}")
    try:
        system("cp .zshrc ~ && cp .p10k.zsh ~")
        system("chmod +x requirements.sh")
        system("./requirements.sh")
        print(f"{GREEN}✅ Todos los requisitos han sido instalados.{RESET}")
    except Exception as e:
        print(f"{RED}❌ Error durante la instalación de dependencias: {e}{RESET}")
        exit(1)

def clear_screen():
    """Limpia la pantalla"""
    system("clear")

def show_loading_message(message, delay=1):
    """Muestra un mensaje de carga con un pequeño retraso"""
    print(f"{MAGENTA}{message}{RESET}")
    time.sleep(delay)

def start():
    clear_screen()
    banner()
    print(f"{GREEN}Este programa te ayudará con tus necesidades de empaquetado.{RESET}")
    print(f"{YELLOW}Sigamos los pasos iniciales...{RESET}\n")
    install_dependencies()
    show_loading_message("Cargando menú principal...")
    clear_screen()

def main():
    start()
    menu()

if __name__ == "__main__":
    main()
