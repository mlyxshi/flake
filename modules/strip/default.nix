# Remove and disable unnecessary modules
{ pkgs, lib, config, ... }: {
  # https://nixos.org/manual/nixos/unstable/#sec-replace-modules
  disabledModules = [
    "services/network-filesystems/samba.nix"
  ];

  imports = [ ];

  programs.nano.enable = false;
  programs.less.enable = lib.mkForce false;
  programs.command-not-found.enable = false;
  boot.bcache.enable = false;
  services.lvm.enable = false;
  environment.stub-ld.enable = false;
}
