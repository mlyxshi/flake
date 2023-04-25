{ pkgs, lib, config, ... }:

{

  options.boot.initrd.services.lvm.enable = lib.mkEnableOption "lvm";
  options.boot.initrd.services.swraid.enable = lib.mkEnableOption "swraid";
  options.boot.initrd.services.swraid.mdadmConf = lib.mkOption {
    type = lib.types.lines;
    default = "";
  };

  config = { };

  # uncessary stuff
  disabledModules = [
    "tasks/lvm.nix"
    "tasks/swraid.nix"
  ];


}
