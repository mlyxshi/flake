cd ~/flake
nix build .#homeConfigurations.asahi.activation-script
./result/activate

sudo mkdir -p /etc/firefox/policies
sudo ln -sf /home/dominic/flake/config/etc/firefox/policies/policies.json /etc/firefox/policies/policies.json

echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/input.rules
sudo usermod -aG input dominic

dnf check-update
sudo dnf install code neochat mpv

sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install org.telegram.desktop

# kde connect
sudo systemctl disable firewalld.service --now

