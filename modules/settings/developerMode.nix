{ pkgs, lib, config, ... }:
let
  cfg = config.settings.developerMode;
in
{
  options = {
    settings.developerMode = lib.mkEnableOption "install extra dev package";
  };

  config = lib.mkIf cfg.enable { };
}
