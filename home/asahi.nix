{ pkgs, lib, config, ... }: {
  imports =[
    ./linux.nix
  ];
  
  programs.firefox.package = lib.mkForce pkgs.firefox;
  programs.firefox.policies = (import ./firefox/policy.nix).policies;
}
