# Remove and disable unnecessary modules
{ pkgs, lib, config, ... }: {
  # https://nixos.org/manual/nixos/unstable/#sec-replace-modules
  disabledModules = [

  ];

  imports = [ ];

  config = {
    programs.nano.enable = false;
    boot.bcache.enable = false;
    services.lvm.enable = false;
  };
}
