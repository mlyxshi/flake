cd ~/flake
nix build .#homeConfigurations.asahi.activation-script
./result/activate

git clone https://github.com/RedBearAK/toshy ~/toshy
cd ~/toshy
./setup_toshy.py install

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

dnf check-update
sudo dnf install code neochat
sudo dnf remove firefox

# kde connect
sudo systemctl disable firewalld.service --now
