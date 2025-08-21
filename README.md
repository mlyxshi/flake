### Nix
```
curl -sL https://install.determinate.systems/nix | sh -s -- install 
nix profile add nixpkgs#nixos-install-tools 
nixos-generate-config 
```

### Darwin
```
curl -sL https://install.determinate.systems/nix | sh -s -- install --determinate
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
git clone --depth=1  https://github.com/mlyxshi/flake.git ~/flake


# change default shell to fish
sudo bash -c 'echo "/run/current-system/sw/bin/fish" >> /etc/shells' 
chsh -s /run/current-system/sw/bin/fish dominic
```


### Todo