nixpkgs:
let
  lib = nixpkgs.lib;
  pkgs = nixpkgs.legacyPackages.aarch64-darwin;
in
rec {
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

  packagelist = pureName (ls ./pkgs);
  getPkgPlatforms = name: (pkgs.callPackage ./pkgs/${name} { }).meta.platforms;
  getArchPkgs = arch: builtins.filter (name: builtins.any (platform: platform == arch) (getPkgPlatforms name)) packagelist;
}
