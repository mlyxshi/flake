{ pkgs, lib, config, ... }:

{
  #options.services.lvm.enable = lib.mkEnableOption "lvm";
  options.boot.initrd.services.lvm.enable = lib.mkEnableOption "lvm";
  options.boot.initrd.services.swraid.enable = lib.mkEnableOption "swraid";

  config = {

  };

    # uncessary stuff
  disabledModules = [ 
    "tasks/lvm.nix"
    "tasks/swraid.nix"
  ];

  
}
