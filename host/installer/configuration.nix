{ modulesPath, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix")
  ];

  services.getty.autologinUser = lib.mkForce "root";
}