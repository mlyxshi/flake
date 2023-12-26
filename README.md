### nix
```
curl -sL https://install.determinate.systems/nix | sh -s -- install
```
### home-manager
```
git clone --depth=1  https://github.com/mlyxshi/flake.git ~/flake
cd ~/flake
nix build .#homeConfigurations.XXX.activation-script
./result/activate
```
### config
```
nix profile install nixpkgs#fd
nix profile install nixpkgs#joshuto
nix profile install nixpkgs#helix

chmod +x config.sh
./config.sh
```

### Asahi Linux
```
diskutil apfs deleteContainer disk0s3

diskutil eraseVolume free free disk0s4
diskutil eraseVolume free free disk0s5

curl https://alx.sh | sh

curl -sL https://install.determinate.systems/nix | sh -s -- install

git clone https://github.com/mlyxshi/flake.git ~/flake
cd ~/flake
nix build .#homeConfigurations.asahi.activation-script
./result/activate

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

dnf check-update
sudo dnf install code neochat
sudo dnf remove firefox

# kconsole default profile set fish

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/RobotoMonoNerdFont-Regular.ttf

git clone https://github.com/RedBearAK/toshy ~/toshy
cd ~/toshy
./setup_toshy.py install
```
