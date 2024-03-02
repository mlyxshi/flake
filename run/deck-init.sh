nix run ~/flake#homeConfigurations.deck.activationPackage

sudo mkdir -p /etc/firefox/policies
nix eval --json --file /home/deck/flake/home/firefox/policy.nix  | sudo tee /etc/firefox/policies/policies.json

echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/input.rules
sudo usermod -aG input deck

sudo systemctl enable --now sshd

mkdir -p ~/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe" > ~/.ssh/authorized_keys

flatpak install flathub cn.xfangfang.wiliwili
flatpak install flathub com.transmissionbt.Transmission
flatpak install flathub tv.kodi.Kodi