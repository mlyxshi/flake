### Nix
```
curl -sL https://install.determinate.systems/nix | sh -s -- install
```

### Darwin
```
git clone --depth=1  https://github.com/mlyxshi/flake.git ~/flake
nix run ~/flake.#homeConfigurations.XXX.activationPackage
```

### Asahi Linux
```
curl https://alx.sh | sh

curl -sL https://install.determinate.systems/nix | sh -s -- install
git clone https://github.com/mlyxshi/flake.git ~/flake
nix run ~/flake#asahi-init
```

### Steam Deck
```
curl -sL https://install.determinate.systems/nix | sh -s -- install

git clone https://github.com/mlyxshi/flake.git ~/flake
nix run ~/flake#deck-init
```

### Todo