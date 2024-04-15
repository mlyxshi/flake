let
  flake = builtins.getFlake (toString ./.);
  nixpkgs = flake.inputs.nixpkgs;
  pkgs = import nixpkgs { system = builtins.currentSystem; };
  lib = pkgs.lib;
  utils = import ./utils.nix nixpkgs;
in
{
  inherit (utils) ls pureName mkFileHierarchyAttrset;
}

// builtins // pkgs // lib // flake
