nixpkgs:
let
  inherit (nixpkgs) lib;
in
rec {
  modulesFromDirectoryRecursive = _dirPath:lib.packagesFromDirectoryRecursive {
    callPackage = path: _: import path;
    directory = _dirPath;
  };
}
