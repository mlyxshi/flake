nix run ~/flake#homeConfigurations.deck.activationPackage

echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/input.rules
sudo usermod -aG input deck

sudo systemctl enable --now sshd

flatpak install cn.xfangfang.wiliwili
flatpak install tv.kodi.Kodi
flatpak install org.yuzu_emu.yuzu