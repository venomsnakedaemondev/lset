from packager.menu import  menu
from os import system

def start():
    system("clear")
    print("Welcome to the packager!")
    print("This program is designed to help you with your packaging needs.")
    print("Please follow the instructions in the menu to get started.")
    system('chmod +x requirements.sh')
    # Install the requirements
    system('./requirements.sh')
    system("sleep 2")
    print("All requirements have been installed.")
    system("sleep 2")
    system("clear")
    print("Welcome to the packager!")
    system("sleep 2")
    system("clear")
def main():
    start()
    menu()

if __name__ == "__main__":
    main()