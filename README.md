### Nix
```
curl -sL https://install.determinate.systems/nix | sh -s -- install
```

### Darwin
```
git clone --depth=1  https://github.com/mlyxshi/flake.git ~/flake
cd ~/flake
nix build .#homeConfigurations.XXX.activation-script
./result/activate

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
chmod +x asahi.sh && ./asahi.sh

# kconsole default profile set fish
# bottom pannel set autohide
```
