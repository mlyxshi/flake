let
  flake = builtins.getFlake (toString ./.);
  nixpkgs = flake.inputs.nixpkgs;
  pkgs = import nixpkgs { system = builtins.currentSystem; };
  lib = pkgs.lib;
  ls = dir: builtins.attrNames (builtins.readDir dir);
  pureName = pathList: map (path: lib.strings.removeSuffix ".nix" path) pathList;
  mkFileHierarchyAttrset = basedir: dir: nixpkgs.lib.genAttrs (pureName (ls ./${basedir}/${dir})) (file: if nixpkgs.lib.sources.pathIsRegularFile ./${basedir}/${dir}/${file}.nix then import ./${basedir}/${dir}/${file}.nix else if builtins.pathExists ./${basedir}/${dir}/${file}/default.nix then import ./${basedir}/${dir}/${file} else mkFileHierarchyAttrset "./${basedir}/${dir}" file);
in
{ 
  inherit mkFileHierarchyAttrset;
  inherit ls;
  inherit pureName;
}

// builtins
// pkgs
// lib
  // flake
