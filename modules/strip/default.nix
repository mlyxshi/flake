# Remove and disable unnecessary modules
{ pkgs, lib, config, ... }: {
  # https://nixos.org/manual/nixos/unstable/#sec-replace-modules
  disabledModules = [

  ];

  imports = [ ];

  programs.nano.enable = false;
  programs.less.enable = false; 
  programs.command-not-found.enable = false;
  boot.bcache.enable = false;
  services.lvm.enable = false;
  environment.stub-ld.enable = false;
}
