{
  pkgs ? import <nixpkgs> { },
}:
{
  commit-notifier = pkgs.callPackage ./commit-notifier.nix { };
  transmission = pkgs.callPackage ./transmission.nix { };
}
# nix-update commit-notifier --version=branch
# nix-update transmission