{ lib }:
let
  ls = dir: builtins.attrNames (builtins.readDir dir);
  pureName = pathList: map (path: lib.strings.removeSuffix ".nix" path) pathList;
  mkModules = dir: lib.genAttrs (pureName (ls ./${dir})) (file: if lib.sources.pathIsDirectory ./${dir}/${file} then import ./${dir}/${file} else import ./${dir}/${file}.nix);
in
lib.genAttrs (ls ./.) (dir: mkModules dir)
# {
#   network = mkModules "network";
#   fileSystem = mkModules "fileSystem";
#   darwin = mkModules "darwin";
#   nixos = mkModules "nixos";
#   settings = mkModules "settings";
#   containers = mkModules "containers";
#   services =  mkModules "services";
# }


