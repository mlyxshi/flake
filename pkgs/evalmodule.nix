{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:
{

  # module system call each module [config, options, lib, specialArgs, _module.args]

  hello = lib.evalModules {
    modules = [
      {
        _module.args.test-module-arg = "test-module-arg-value";
        _module.args.pkgs = pkgs;
      }
      ./module-test.nix
    ];
    specialArgs = {
      test-specialArg = "test-specialArg-value";
      modulesPath = "";
    };
  };
}
