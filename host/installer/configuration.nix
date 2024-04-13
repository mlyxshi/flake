{ modulesPath, lib, pkgs, ... }: {
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

  # https://github.com/NixOS/nixpkgs/blob/84d2fa520e16fd45d99a69d6a0bb25d9e096327f/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix#L6
  nixpkgs.overlays = [
    (final: super: {
      zfs = super.zfs.overrideAttrs (_: { meta.platforms = [ ]; });
    })
  ];

  environment.systemPackages = with pkgs; [ iwd cloudflared ];

  system.disableInstallerTools = lib.mkForce false;
  services.getty.autologinUser = lib.mkForce "root";

  systemd.sysusers.enable = lib.mkForce false;
  system.etc.overlay.enable = lib.mkForce false;

  users.users.root.shell = lib.mkForce pkgs.bashInteractive;
}
