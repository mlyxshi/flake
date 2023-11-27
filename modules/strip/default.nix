# Remove and disable unnecessary modules
{ pkgs, lib, config, ... }: {
  # dummy options to make other modules happy
  options.services.lvm.enable = lib.mkEnableOption "lvm";
  options.boot.initrd.services.lvm.enable = lib.mkEnableOption "lvm";

  # https://nixos.org/manual/nixos/unstable/#sec-replace-modules
  disabledModules = [
    "tasks/lvm.nix"
  ];

  imports = [
  ];

  config = {
    programs.nano.enable = false;
    boot.bcache.enable = false;
  };
}
