{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

  boot.supportedFilesystems.zfs = lib.mkForce false;
  boot.initrd.systemd.enable = true;

  environment.systemPackages = with pkgs; [
    iwd
  ];

  system.disableInstallerTools = lib.mkForce false;
  services.getty.autologinUser = lib.mkForce "root";

  users.users.root.shell = lib.mkForce pkgs.bashInteractive;
}
