{ modulesPath, lib, pkgs, ... }:
let
  rootPartType = {
    x64 = "4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709";
    aa64 = "B921B045-1DF0-41C3-AF44-4C6F280D3FAE";
  }.${pkgs.stdenv.hostPlatform.efiArch};
in
{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

  # https://github.com/NixOS/nixpkgs/blob/84d2fa520e16fd45d99a69d6a0bb25d9e096327f/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix#L6
  nixpkgs.overlays = [
    (final: super: {
      zfs = super.zfs.overrideAttrs (_: { meta.platforms = [ ]; });
    })
  ];

  environment.systemPackages = with pkgs; [
    iwd

    (pkgs.writeShellScriptBin "make-partitions" ''
      sgdisk --zap-all /dev/sda
      sgdisk --new=0:0:+512M --typecode=0:ef00 /dev/sda
      sgdisk --new=0:0:0 --typecode=0:${rootPartType} /dev/sda
    '')

    (pkgs.writeShellScriptBin "mount-partitions" ''
      mkfs.fat -F 32 /dev/sda1
      mkfs.ext4 -F /dev/sda2
      mkdir -p /mnt
      mount /dev/sda2 /mnt
      mount --mkdir /dev/sda1 /mnt/boot
    '')

    (pkgs.writeShellScriptBin "install" ''
      HOST=$1

      make-partitions
      mount-partitions

      nix build --build-users-group "" --store /mnt --profile /mnt/nix/var/nix/profiles/system github:mlyxshi/flake#nixosConfigurations.$HOST.config.system.build.toplevel

      mkdir /mnt/{etc,tmp}
      touch /mnt/etc/NIXOS
      NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root /mnt -- /run/current-system/bin/switch-to-configuration boot
      reboot
    '')

  ];

  system.disableInstallerTools = lib.mkForce false;
  services.getty.autologinUser = lib.mkForce "root";

  systemd.sysusers.enable = lib.mkForce false;
  system.etc.overlay.enable = lib.mkForce false;

  users.users.root.shell = lib.mkForce pkgs.bashInteractive;
}
