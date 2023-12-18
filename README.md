### install nix
```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```
### install hm
```
git clone --depth=1  git@github.com:mlyxshi/flake ~/flake
cd ~/flake
nix build .#homeConfigurations.aarch64-linux.activation-script
```
