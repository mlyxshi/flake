### install nix
```
curl -sL https://install.determinate.systems/nix | sh -s -- install
```
### install home-manager
```
git clone --depth=1  https://github.com/mlyxshi/flake.git ~/flake
cd ~/flake
nix profile install nixpkgs#fd
nix profile install nixpkgs#joshuto
nix profile install nixpkgs#helix
nix build .#homeConfigurations.aarch64-linux.activation-script
./result/activate
```
