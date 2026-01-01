#!/bin/bash

LOCAL=".local"

bash deps.sh
sleep 3

echo "[+] Copying the rices to $HOME/.rices |---------------------------------------------"
echo ""

if [[ -d ~/.rices ]]; then
    rm -rf ~/.rices
    cp -r .rices ~/.rices
else
    cp -r .rices ~/.rices
fi

echo ""
sleep 3
echo "[+] Backing up your old config to $HOME/config.old |----------------------------------------------------"
echo ""
mv ~/.config ~/config.old
echo ""
sleep 3
echo "[+] Copying the configs to $HOME/.config |-----------------------------------------------------------------"
echo ""
cp -r .config/ ~/.config/
echo ""
sleep 3
echo "[+] Copying the required binaries to ~/.local/bin |----------------------------------------------------------"
echo ""
cp -r $LOCAL/bin/* ~/$LOCAL/bin/
echo ""
sleep 3
echo "[+] Setting up the rice manager for bspwm |-----------------------------------------------------------------"
echo "[NOTE] This is a fully cli manager.."
echo ""
echo "#############################################" >> ~/.zshrc
echo "# IMPORT THE FUNCTIONS FROM RICE MANAGER" >> ~/.zshrc
echo "#############################################" >> ~/.zshrc
echo "source ~/.rices/current-rice" >> ~/.zshrc
echo "source ~/.rices/rice-functions.zsh" >> ~/.zshrc
echo "[+] Reloading your zshrc config..."
source ~/.zshrc
sleep 3
echo "[+] Switching to melissa rice..."
switch_rice melissa

