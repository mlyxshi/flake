### Nix
```
curl -sL https://install.determinate.systems/nix | sh -s -- install
```

### Darwin
```
git clone --depth=1  https://github.com/mlyxshi/flake.git ~/flake
nix run ~/flake#homeConfigurations.darwin.activationPackage
```

### Steam Deck
```
curl -sL https://install.determinate.systems/nix | sh -s -- install

git clone https://github.com/mlyxshi/flake.git ~/flake

nix run ~/flake#homeConfigurations.deck.activationPackage
sudo systemctl enable --now sshd

flatpak install cn.xfangfang.wiliwili org.videolan.VLC io.github.pwr_solaar.solaar com.google.Chrome
```

### Todo