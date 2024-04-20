nixpkgs:
let
  inherit (nixpkgs) lib;
  # Caution! arch may be mismatched, but only use to get meta.platforms is fine
  inherit (nixpkgs.legacyPackages.aarch64-darwin) callPackage;
in
rec {
  ls = dir: builtins.attrNames (builtins.readDir dir);

  pureName = pathList:
    map (path: lib.strings.removeSuffix ".nix" path) pathList;

  mkFileHierarchyAttrset = basedir: dirName:
    lib.genAttrs (pureName (ls /.${basedir}/${dirName})) (path:
      if builtins.pathExists /.${basedir}/${dirName}/${path}.nix then
        import /.${basedir}/${dirName}/${path}.nix
      else if builtins.pathExists
        /.${basedir}/${dirName}/${path}/default.nix then
        import /.${basedir}/${dirName}/${path}
      else
        mkFileHierarchyAttrset /.${basedir}/${dirName} path);

  packagelist = pureName (ls ./pkgs);
  getPkgPlatforms = name: (callPackage ./pkgs/${name} { }).meta.platforms;
  getArchPkgs = arch:
    builtins.filter
      (name: builtins.any (platform: platform == arch) (getPkgPlatforms name))
      packagelist;

  oracle-serverlist = ["jp1" "jp2" "us" "de" ];
}
