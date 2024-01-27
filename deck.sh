nix run --extra-substituters https://cache.mlyxshi.com --extra-trusted-public-keys cache:vXjiuWtSTOXj63zr+ZjMvXqvaYIK1atjyyEk+iuIqSg=  ~/flake#homeConfigurations.deck.activationPackage

sudo mkdir -p /etc/firefox/policies
nix eval --json --file /home/deck/flake/home/firefox/policy.nix  | sudo tee /etc/firefox/policies/policies.json

echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/input.rules
sudo usermod -aG input deck

sudo systemctl enable --now sshd
