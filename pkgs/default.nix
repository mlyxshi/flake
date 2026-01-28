{
  pkgs ? import <nixpkgs> { },
}:
{
  commit-notifier = pkgs.callPackage ./commit-notifier.nix { };
  transmission = pkgs.callPackage ./transmission.nix { };
}
