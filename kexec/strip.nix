# disable uncessary modules
{ pkgs, lib, config, ... }:{
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
    "system/boot/systemd/initrd.nix"
  ];

}
