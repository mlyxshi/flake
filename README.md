### Nix
```
curl -sL https://install.determinate.systems/nix | sh -s -- install
```

### Darwin
```
git clone --depth=1  https://github.com/mlyxshi/flake.git ~/flake
cd ~/flake
nix run .#homeConfigurations.XXX.activationPackage
```

### Asahi Linux
```
diskutil apfs deleteContainer disk0s3

diskutil eraseVolume free free disk0s4
diskutil eraseVolume free free disk0s5

curl https://alx.sh | sh

curl -sL https://install.determinate.systems/nix | sh -s -- install  --extra-conf "trusted-users = root dominic"

git clone https://github.com/mlyxshi/flake.git ~/flake
chmod +x asahi.sh && ./asahi.sh
```

### Steam Deck
```
curl -sL https://install.determinate.systems/nix | sh -s -- install --extra-conf "trusted-users = root deck"

git clone https://github.com/mlyxshi/flake.git ~/flake
chmod +x deck.sh && ./deck.sh
```
