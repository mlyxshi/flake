### Nix
```
curl -sL https://install.determinate.systems/nix | sh -s -- install
nix profile install nixpkgs#nixos-install-tools 
nixos-generate-config 
```

### Darwin
```
git clone --depth=1  https://github.com/mlyxshi/flake.git ~/flake
```


### Todo