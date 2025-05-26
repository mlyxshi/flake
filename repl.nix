let
  flake = builtins.getFlake (toString ./.);
  nixpkgs = flake.inputs.nixpkgs;
  pkgs = import nixpkgs { system = builtins.currentSystem; };
  lib = pkgs.lib;
  utils = import ./utils.nix nixpkgs;
in
{
  inherit (utils) modulesFromDirectoryRecursive;
}

// builtins // pkgs // lib // flake
