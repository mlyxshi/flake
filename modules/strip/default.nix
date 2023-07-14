# Remove and disable unnecessary modules
{ pkgs, lib, config, ... }: {
  # dummy options to make other modules happy
  options.services.lvm.enable = lib.mkEnableOption "lvm";
  options.boot.initrd.services.lvm.enable = lib.mkEnableOption "lvm";

  # https://nixos.org/manual/nixos/unstable/#sec-replace-modules
  disabledModules = [
    "tasks/lvm.nix"
    "tasks/bcache.nix"
    "system/boot/systemd/initrd.nix"

    "programs/nano.nix"
  ];

  imports = [
    ./patched-initrd.nix
  ];

  config = { };
}
