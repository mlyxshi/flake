{ lib }:
let
  ls = dir: builtins.attrNames (builtins.readDir dir);
  pureName = pathList: map (path: if lib.strings.hasSuffix ".nix" path then lib.strings.removeSuffix ".nix" path else path) pathList;
in
{
  network = import ./network;
  fileSystem = import ./fileSystem;
  os.darwin = import ./os/darwin;
  os.nixos = lib.genAttrs (pureName (ls ./os/nixos)) (file: import ./os/nixos/${file}.nix);
  settings = lib.genAttrs (pureName (ls ./settings)) (file: import ./settings/${file}.nix);
  containers = lib.genAttrs (pureName (ls ./containers)) (file: import ./containers/${file}.nix);
  services = lib.genAttrs (pureName (ls ./services)) (file: if lib.sources.pathIsDirectory ./services/${file} then import ./services/${file} else import ./services/${file}.nix);
}
