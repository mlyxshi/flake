### nix
```
curl -sL https://install.determinate.systems/nix | sh -s -- install
```
### home-manager
```
git clone --depth=1  https://github.com/mlyxshi/flake.git ~/flake
cd ~/flake
nix build .#homeConfigurations.aarch64-linux.activation-script
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