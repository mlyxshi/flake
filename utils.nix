{ lib }: rec{
  ls = dir: builtins.attrNames (builtins.readDir dir);
  pureName = pathList: map (path: lib.strings.removeSuffix ".nix" path) pathList;
  mkFileHierarchyAttrset = basedir: dir: lib.genAttrs (pureName (ls ./${basedir}/${dir})) (path: if lib.sources.pathIsRegularFile ./${basedir}/${dir}/${path}.nix then import ./${basedir}/${dir}/${path}.nix else if builtins.pathExists ./${basedir}/${dir}/${path}/default.nix then import ./${basedir}/${dir}/${path} else mkFileHierarchyAttrset "./${basedir}/${dir}" path);
}
