{ lib }:
let
  ls = dir: builtins.attrNames (builtins.readDir dir);
  pureName = pathList: map (path: lib.strings.removeSuffix ".nix" path) pathList;
  mkModules = dir: lib.genAttrs (pureName (ls ./${dir})) (file: if lib.sources.pathIsDirectory ./${dir}/${file} then import ./${dir}/${file} else import ./${dir}/${file}.nix);
in
{
  network = import ./network;
  fileSystem = import ./fileSystem;
  os.darwin = import ./os/darwin;
  os.nixos = lib.genAttrs (pureName (ls ./os/nixos)) (file: import ./os/nixos/${file}.nix);
  settings = lib.genAttrs (pureName (ls ./settings)) (file: import ./settings/${file}.nix);
  containers = lib.genAttrs (pureName (ls ./containers)) (file: import ./containers/${file}.nix);
  services =  mkModules "services";
}
