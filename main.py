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
║    🚀 Bienvenido a {YELLOW}Packager{CYAN}!║
║                                            ║
╚════════════════════════════════════════════╝{RESET}
""")

def start():
    system("clear")
    banner()
    print(f"{GREEN}Este programa te ayudará con tus necesidades de empaquetado.{RESET}")
    print(f"{YELLOW}Sigamos los pasos iniciales...{RESET}\n")

    print(f"{CYAN}⏳ Instalando dependencias...{RESET}")
    system("chmod +x requirements.sh")
    system("./requirements.sh")
    print(f"{GREEN}✅ Todos los requisitos han sido instalados.{RESET}")
    
    time.sleep(2)
    system("clear")
    banner()
    print(f"{MAGENTA}Cargando menú principal...{RESET}")
    time.sleep(1)
    system("clear")

def main():
    start()
    menu()

if __name__ == "__main__":
    main()
