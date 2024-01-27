nix run ~/flake#homeConfigurations.asahi.activationPackage

sudo mkdir -p /etc/firefox/policies
nix eval --json --file ./home/firefox/policy.nix  | sudo tee /etc/firefox/policies/policies.json

echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/input.rules
sudo usermod -aG input dominic

dnf check-update
sudo dnf install code neochat mpv

sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install org.telegram.desktop

# kde connect
sudo systemctl disable firewalld.service --now

