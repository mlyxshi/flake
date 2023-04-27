{ pkgs, lib, config, ... }:{
  # dummy options to make other modules happy
  options.services.lvm.enable = lib.mkEnableOption "lvm";
  options.boot.initrd.services.lvm.enable = lib.mkEnableOption "lvm";
  options.boot.initrd.services.swraid.enable = lib.mkEnableOption "swraid";
  options.boot.initrd.services.swraid.mdadmConf = lib.mkOption {
    type = lib.types.lines;
    default = "";
  };

  config = { 

  };

  disabledModules = [
    "tasks/lvm.nix"
    "tasks/swraid.nix"
    "tasks/bcache.nix"
    "system/boot/systemd/initrd.nix" # https://nixos.org/manual/nixos/unstable/#sec-replace-modules
  ];

}
