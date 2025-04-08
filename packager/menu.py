from colorama import Fore, Style, init

# Initialize colorama
init(autoreset=True)

def show_menu():
    print(Fore.CYAN + "========== Main Menu ==========")
    print(Fore.YELLOW + "1. instalation")
    print(Fore.YELLOW + "2. Option 2")
    print(Fore.YELLOW + "3. Exit")
    print(Fore.CYAN + "===============================")

def execute_option(option):
    if option == "1":
        print(Fore.GREEN + "You selected Option 1")
    elif option == "2":
        print(Fore.GREEN + "You selected Option 2")
    elif option == "3":
        print(Fore.RED + "Exiting the program. Goodbye!")
    else:
        print(Fore.RED + "Invalid option. Please try again.")

def menu():
    while True:
        show_menu()
        option = input(Fore.MAGENTA + "Choose an option: ")
        if option == "3":
            execute_option(option)
            break
        execute_option(option)

if __name__ == "__main__":
    menu()
