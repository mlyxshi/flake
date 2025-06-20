{ modulesPath, lib, pkgs, ... }:
let
  rootPartType = {
    x64 = "4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709";
    aa64 = "B921B045-1DF0-41C3-AF44-4C6F280D3FAE";
  }.${pkgs.stdenv.hostPlatform.efiArch};
in
{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

  boot.supportedFilesystems.zfs = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    iwd
  ];

  system.disableInstallerTools = lib.mkForce false;
  services.getty.autologinUser = lib.mkForce "root";

  users.users.root.shell = lib.mkForce pkgs.bashInteractive;
}
