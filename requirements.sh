sudo pacman -Syu --noconfirm 
sudo pacman -S python python-colorama git jq zsh  --noconfirm

set -e  # Detener script si ocurre algún error

# Colores ANSI
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

echo -e "${CYAN}🔄 Actualizando el sistema...${RESET}"
sudo pacman -Syu --noconfirm

sleep 1
echo -e "${YELLOW}📦 Instalando paquetes base...${RESET}"
sleep 2

# Instalar yay
echo -e "${CYAN}⬇️ Clonando yay desde AUR...${RESET}"
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay
echo -e "${GREEN}✅ yay instalado correctamente.${RESET}"

# Instalar paru
echo -e "${CYAN}⬇️ Clonando paru desde AUR...${RESET}"
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ..
rm -rf paru
echo -e "${GREEN}✅ paru instalado correctamente.${RESET}"

echo -e "${GREEN}🎉 Todo listo. Las herramientas base han sido instaladas.${RESET}"

sudo su c
hsh -s /bin/zsh
exit 
echo $USER
chsh -s /bin/zsh


