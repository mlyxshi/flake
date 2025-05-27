let
  flake = builtins.getFlake (toString ./.);
  nixpkgs = flake.inputs.nixpkgs;
  pkgs = import nixpkgs { system = builtins.currentSystem; };
  lib = pkgs.lib;
  utils = import ./utils.nix { inherit self nixpkgs secret; };
in
{
  inherit (utils) modulesFromDirectoryRecursive;
}

// builtins // pkgs // lib // flake
