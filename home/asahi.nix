{ pkgs, lib, config, ... }: {
  programs.firefox.package = lib.mkForce pkgs.firefox;
  programs.firefox.policies = import ./firefox/policy.nix;
}
