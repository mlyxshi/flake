let
  flake = builtins.getFlake (toString ./.);
  nixpkgs = flake.inputs.nixpkgs;
  pkgs = import nixpkgs { system = builtins.currentSystem; };
  lib = pkgs.lib;
  ls = dir: builtins.attrNames (builtins.readDir dir);
  pureName = pathList: map (path: lib.strings.removeSuffix ".nix" path) pathList;
  mkFileHierarchyAttrset = basedir: dir:
  lib.genAttrs (pureName (ls ./${basedir}/${dir}))
    (path:
      if builtins.pathExists ./${basedir}/${dir}/${path}.nix
      then import ./${basedir}/${dir}/${path}.nix
      else if builtins.pathExists ./${basedir}/${dir}/${path}/default.nix
      then import ./${basedir}/${dir}/${path}
      else mkFileHierarchyAttrset "./${basedir}/${dir}" path
    );
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
