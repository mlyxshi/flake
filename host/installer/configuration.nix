{ modulesPath, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
  ];

  services.getty.autologinUser = lib.mkForce "root";
  boot.kernelPackages = lib.mkForce pkgs.zfs.latestCompatibleLinuxPackages;
}
