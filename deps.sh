#!/bin/bash

echo "[+] Installing required dependencies..."
echo "[+] Make sure that you have paru installed as AUR helper..."
aurdeps=(vicinae-bin deadd-notification-center-bin picom-ftlabs-git)
pacdeps=(obsidian tor torsocks papirus-icon-theme alacritty kitty polybar bspwm sxhkd dunst)
pacfonts=(ttf-fira-code ttf-jetbrains-mono noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-dejavu ttf-liberation ttf-nerd-fonts-symbols)
aurfonts=(ttf-material-design-icons-desktop-git ttf-material-design-iconic-font ttf-material-icons-git)
themes=(juno-mirage-standard-buttons-gtk-theme-git juno-mirage-gtk-theme-git colloid-catppuccin-theme-git tela-icon-theme)

echo "[+] Updating packages..."
paru -Syu
echo "[+] Installing AUR dependencies..."
for i in $aurdeps; do
    echo ""
    echo "[INSTALLING] : $i |----------------------------------------------------------"
    echo ""
    paru -S --needed "$i"
    echo ""
done
echo "[+] Installing Pacman dependencies..."
for i in $pacdeps; do
    echo ""
    echo "[INSTALLING] : $i |-----------------------------------------------------------"
    echo ""
    sudo pacman -S --needed "$i"
    echo ""
done
echo "[+] Installing Pacman fonts..."
for i in $pacfonts; do
    echo ""
    echo "[INSTALLING] : $i |-----------------------------------------------------------"
    echo ""
    sudo pacman -S --needed "$i"
    echo ""
done
echo "[+] Installing AUR fonts..."
for i in $aurfonts; do
    echo ""
    echo "[INSTALLING] : $i |-----------------------------------------------------------"
    echo ""
    paru -S --needed "$i"
    echo ""
done
echo "[+] Installing required themes..."
for i in $themes; do
    echo ""
    echo "[INSTALLING] : $i |-----------------------------------------------------------"
    echo ""
    paru -S --needed "$i"
    echo ""
done

