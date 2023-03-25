{ pkgs, lib, config, ... }:
let
  cfg = config.settings.nixConfigDir;
in
{
  options = {
    settings.nixConfigDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };
}
