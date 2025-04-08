import subprocess
import time
from datetime import datetime
import platform
import argparse
import logging
import shlex
from logging.handlers import RotatingFileHandler
from typing import Optional, Union, List
from packager.menu import menu
import os

# Colores ANSI
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
BLUE = "\033[94m"
MAGENTA = "\033[95m"
CYAN = "\033[96m"
RESET = "\033[0m"
BOLD = "\033[1m"

# Configuración avanzada de logging
def setup_logging():
    """Configura el sistema de logging con rotación de archivos"""
    log_formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
    
    # Handler para archivo con rotación
    file_handler = RotatingFileHandler(
        "packager.log",
        maxBytes=1024*1024,  # 1MB
        backupCount=3,
        encoding='utf-8'
    )
    file_handler.setFormatter(log_formatter)
    file_handler.setLevel(logging.INFO)
    
    # Handler para consola
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(log_formatter)
    console_handler.setLevel(logging.WARNING)
    
    # Configurar el logger principal
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)
    
    return logger

logger = setup_logging()

def banner():
    """Muestra el banner de bienvenida"""
    print(f"""{CYAN}{BOLD}
╔════════════════════════════════════════════╗
║                                            ║
║      🚀 Bienvenido a {YELLOW}Packager{CYAN}!                  ║
║                                            ║
╚════════════════════════════════════════════╝{RESET}
""")

def log_event(event: str, level: str = "info") -> None:
    """Registra eventos en el archivo de log
    
    Args:
        event (str): Mensaje a registrar
        level (str): Nivel de log ('info', 'warning', 'error')
    """
    if level == "info":
        logger.info(event)
    elif level == "warning":
        logger.warning(event)
    elif level == "error":
        logger.error(event)

def check_platform() -> None:
    """Verifica que el sistema operativo sea compatible"""
    os_name = platform.system()
    if os_name not in ["Linux", "Darwin", "Windows"]:
        print(f"{RED}❌ Sistema operativo no compatible: {os_name}{RESET}")
        log_event(f"Sistema operativo no compatible: {os_name}", level="error")
        exit(1)
    log_event(f"Sistema operativo detectado: {os_name}")

def check_files_exist(files: List[str]) -> bool:
    """Verifica que los archivos necesarios existan
    
    Args:
        files (List[str]): Lista de archivos a verificar
        
    Returns:
        bool: True si todos los archivos existen, False si alguno falta
    """
    missing_files = [file for file in files if not os.path.exists(file)]
    
    if missing_files:
        for file in missing_files:
            print(f"{RED}❌ Archivo no encontrado: {file}{RESET}")
            log_event(f"Archivo no encontrado: {file}", level="error")
        return False
    
    return True

def run_command(command: Union[str, List[str]], max_retries: int = 3) -> Optional[str]:
    """Ejecuta un comando en el sistema con reintentos
    
    Args:
        command (Union[str, List[str]]): Comando a ejecutar
        max_retries (int): Número máximo de reintentos
        
    Returns:
        Optional[str]: Salida del comando o None si falló
    """
    # Convertir lista de comandos a string seguro
    if isinstance(command, list):
        safe_cmd = ' '.join(shlex.quote(arg) for arg in command)
    else:
        safe_cmd = shlex.quote(command)
    
    attempt = 0
    while attempt < max_retries:
        try:
            result = subprocess.run(
                safe_cmd,
                shell=True,
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                encoding='utf-8'
            )
            
            log_msg = f"Comando ejecutado: {safe_cmd}"
            if result.stdout.strip():
                log_msg += f"\nSalida: {result.stdout.strip()}"
            
            print(f"{GREEN}✅ Comando ejecutado: {safe_cmd}{RESET}")
            log_event(log_msg)
            
            return result.stdout
        
        except subprocess.CalledProcessError as e:
            attempt += 1
            error_msg = (f"Error ejecutando comando (intento {attempt}/{max_retries}): {safe_cmd}\n"
                         f"Código de error: {e.returncode}\n"
                         f"Salida de error: {e.stderr.strip()}")
            
            print(f"{YELLOW}⚠️ {error_msg}{RESET}")
            log_event(error_msg, level="warning" if attempt < max_retries else "error")
            
            if attempt < max_retries:
                time.sleep(2)  # Espera antes de reintentar
    
    print(f"{RED}❌ Fallo al ejecutar comando después de {max_retries} intentos: {safe_cmd}{RESET}")
    return None

def install_dependencies() -> bool:
    """Instala las dependencias necesarias desde requirements.sh
    
    Returns:
        bool: True si la instalación fue exitosa, False en caso contrario
    """
    print(f"{CYAN}⏳ Instalando dependencias...{RESET}")
    
    required_files = [".zshrc", ".p10k.zsh", "requirements.sh"]
    if not check_files_exist(required_files):
        return False
    
    try:
        # Copiar archivos de configuración
        run_command("cp .zshrc ~")
        run_command("cp .p10k.zsh ~")
        
        # Dar permisos y ejecutar script de requisitos
        run_command("chmod +x requirements.sh")
        run_command("./requirements.sh")
        
        print(f"{GREEN}✅ Todos los requisitos han sido instalados.{RESET}")
        log_event("Dependencias instaladas correctamente.")
        time.sleep(3)
        return True
    
    except Exception as e:
        error_msg = f"Error durante la instalación de dependencias: {str(e)}"
        print(f"{RED}❌ {error_msg}{RESET}")
        log_event(error_msg, level="error")
        return False

def clear_screen() -> None:
    """Limpia la pantalla según el sistema operativo"""
    if platform.system() == "Windows":
        run_command("cls")
    else:
        run_command("clear")

def show_loading_message(message: str, delay: float = 1.0) -> None:
    """Muestra un mensaje de carga con temporizador
    
    Args:
        message (str): Mensaje a mostrar
        delay (float): Tiempo de espera en segundos
    """
    print(f"{MAGENTA}{message}{RESET}")
    time.sleep(delay)

def confirm_action(message: str, max_attempts: int = 3) -> bool:
    """Pide confirmación al usuario antes de realizar una acción
    
    Args:
        message (str): Mensaje de confirmación
        max_attempts (int): Máximo número de intentos
        
    Returns:
        bool: True si el usuario confirma, False si cancela
    """
    valid_responses = {
        's': True, 'si': True, 'y': True, 'yes': True,
        'n': False, 'no': False
    }
    
    attempt = 0
    while attempt < max_attempts:
        response = input(f"{YELLOW}{message} (s/n): {RESET}").lower().strip()
        
        if response in valid_responses:
            if valid_responses[response]:
                return True
            print(f"{CYAN}Operación cancelada.{RESET}")
            log_event("Operación cancelada por el usuario.", level="warning")
            return False
        
        attempt += 1
        print(f"{RED}Respuesta no válida. Intento {attempt}/{max_attempts}{RESET}")
    
    print(f"{RED}Máximo número de intentos alcanzado.{RESET}")
    return False

def show_help() -> None:
    """Muestra la ayuda del programa"""
    print(f"""{CYAN}
Uso: python script.py [opciones]
Opciones:
    -h, --help      Muestra esta ayuda
    -v, --version   Muestra la versión del programa
    -s, --silent    Modo silencioso (sin interacción)
    -d, --debug     Modo depuración (más verboso)
{RESET}""")

def parse_arguments():
    """Configura y parsea los argumentos de línea de comandos"""
    parser = argparse.ArgumentParser(
        description="Packager - Herramienta de empaquetado",
        add_help=False
    )
    
    parser.add_argument(
        "-h", "--help",
        action="store_true",
        help="Muestra esta ayuda"
    )
    parser.add_argument(
        "-v", "--version",
        action="version",
        version="Packager 1.1",
        help="Muestra la versión del programa"
    )
    parser.add_argument(
        "-s", "--silent",
        action="store_true",
        help="Modo silencioso (sin interacción)"
    )
    parser.add_argument(
        "-d", "--debug",
        action="store_true",
        help="Modo depuración (más verboso)"
    )
    
    return parser.parse_args()

def start(args) -> None:
    """Inicia el programa con los argumentos configurados"""
    # Configurar nivel de logging según argumentos
    if args.debug:
        logger.setLevel(logging.DEBUG)
        for handler in logger.handlers:
            handler.setLevel(logging.DEBUG)
    
    check_platform()
    clear_screen()
    banner()
    
    print(f"{GREEN}Este programa te ayudará con tus necesidades de empaquetado.{RESET}")
    
    if not args.silent:
        print(f"{YELLOW}Sigamos los pasos iniciales...{RESET}\n")
        
        if confirm_action("¿Deseas continuar con la instalación de dependencias iniciales?"):
            if not install_dependencies():
                exit(1)
        
        show_loading_message("Cargando menú principal...")
    else:
        log_event("Ejecutando en modo silencioso", level="info")
        install_dependencies()
    
    clear_screen()

def main() -> None:
    """Punto de entrada principal"""
    args = parse_arguments()
    
    if args.help:
        show_help()
        return
    
    start(args)
    menu()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{RED}❌ Programa interrumpido por el usuario.{RESET}")
        log_event("Programa interrumpido por el usuario", level="warning")
        exit(1)
    except Exception as e:
        print(f"\n{RED}❌ Error inesperado: {e}{RESET}")
        log_event(f"Error inesperado: {e}", level="error")
        exit(1)