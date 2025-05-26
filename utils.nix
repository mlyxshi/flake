nixpkgs:
let
  inherit (nixpkgs) lib;
in
rec {
  oracle-serverlist = [ "jp1" "jp2" "us" ];
  modulesFromDirectoryRecursive = _dirPath:lib.packagesFromDirectoryRecursive {
    callPackage = path: _: import path;
    directory = _dirPath;
  };
}
