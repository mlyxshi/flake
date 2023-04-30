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

  oracle-arm64-serverlist = pureName (ls ./host/oracle/aarch64);
  oracle-x64-serverlist = pureName (ls ./host/oracle/x86_64);
  oracle-serverlist = oracle-arm64-serverlist ++ oracle-x64-serverlist;
  
  azure-x64-serverlist = pureName (ls ./host/azure/x86_64);
  azure-serverlist = azure-x64-serverlist;
}
