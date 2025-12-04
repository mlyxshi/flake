# Remove and disable unnecessary modules
{
  pkgs,
  lib,
  config,
  ...
}:
{
  # https://nixos.org/manual/nixos/unstable/#sec-replace-modules
  disabledModules = [
  ];

  programs.nano.enable = false;
  programs.less.enable = lib.mkForce false;
  boot.bcache.enable = false;
  services.lvm.enable = false;
  services.logrotate.enable = false;
  programs.fuse.enable = false;
  environment.stub-ld.enable = false;
}
