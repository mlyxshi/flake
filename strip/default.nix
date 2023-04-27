# Remove and disable unnecessary modules
{ pkgs, lib, config, ... }: {
  # dummy options to make other modules happy
  options.services.lvm.enable = lib.mkEnableOption "lvm";
  options.boot.initrd.services.lvm.enable = lib.mkEnableOption "lvm";
  options.boot.initrd.services.swraid.enable = lib.mkEnableOption "swraid";
  options.boot.initrd.services.swraid.mdadmConf = lib.mkOption {
    type = lib.types.lines;
    default = "";
  };

  # https://nixos.org/manual/nixos/unstable/#sec-replace-modules
  disabledModules = [
    "tasks/lvm.nix"
    "tasks/swraid.nix"
    "tasks/bcache.nix"
    "system/boot/systemd/initrd.nix"

    "programs/nano.nix"
  ];

  imports = [
    ./patched-initrd.nix
  ];

  config = { };
}
