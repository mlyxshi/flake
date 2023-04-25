{ pkgs, lib, config, ... }:

{
  options.services.lvm.enable = lib.mkEnableOption "lvm";

  config = {

  };

    # uncessary stuff
  disabledModules = [ 
    "tasks/lvm.nix"
    "tasks/swraid.nix"
  ];

  
}
