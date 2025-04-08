from colorama import Fore, Style, init
from os import system
from packager.scripts.install import install

# Inicializa colorama
init(autoreset=True)

def show_menu():
    print(Fore.CYAN + "========== Menú Principal ==========")
    print(Fore.YELLOW + "1. Instalación Base")
    print(Fore.YELLOW + "2. Opción 2")
    print(Fore.YELLOW + "3. Salir")
    print(Fore.CYAN + "====================================")

def execute_option(option):
    if option == "1":
        print(Fore.GREEN + "Has seleccionado la Opción 1")
        try:
            system("chmod +x packager/scripts/base.sh")
            system('sh packager/scripts/base.sh')
        except Exception as e:
            print(Fore.RED + f"Error al ejecutar base.sh: {e}")
            return
        print(Fore.GREEN + "Todos los requisitos base han sido instalados.")
        install()
    elif option == "2":
        print(Fore.GREEN + "Has seleccionado la Opción 2")
    elif option == "3":
        print(Fore.RED + "Saliendo del programa. ¡Adiós!")
    else:
        print(Fore.RED + "Opción no válida. Por favor, intenta nuevamente.")

def menu():
    while True:
        show_menu()
        option = input(Fore.MAGENTA + "Selecciona una opción: ")
        execute_option(option)
        if option == "3":
            break
