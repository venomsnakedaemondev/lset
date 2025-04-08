#!/usr/bin/env bash
sudo pacman -Syu --noconfirm
sleep 2 
echo "Installing base packages..."
echo "This may take a while..."
sleep 3 
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay