### Nix
```
curl -sL https://install.determinate.systems/nix | sh -s -- install
nix profile install nixpkgs#nixos-install-tools 
nixos-generate-config 
```

### Darwin
```
curl -sL https://install.determinate.systems/nix | sh -s -- install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone --depth=1  https://github.com/mlyxshi/flake.git ~/flake
```


### Todo