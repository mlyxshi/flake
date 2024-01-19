cd ~/flake
nix build .#homeConfigurations.deck.activation-script
./result/activate

sudo mkdir -p /etc/firefox/policies
sudo ln -sf /home/deck/flake/config/etc/firefox/policies/policies.json /etc/firefox/policies/policies.json

echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/input.rules
sudo usermod -aG input deck
