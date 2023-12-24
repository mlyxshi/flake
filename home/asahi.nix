{ pkgs, lib, config, ... }: {

 imports = [
    ./standalone.nix
  ];

  home = {
    username = "dominic";
    homeDirectory = "/home/dominic";
  };
  
  programs.firefox.package = lib.mkForce pkgs.firefox;
  programs.firefox.policies = (import ./firefox/policy.nix).policies;
}
