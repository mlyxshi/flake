{ pkgs, lib, self, config, ... }:
let
  package = self.packages.${config.nixpkgs.hostPlatform.system}.komari-agent;
  cfg = config.services.komari-agent;
in
{
  options.services.komari-agent = {
    enable = lib.mkEnableOption "Komari Agent";
    token = lib.mkOption {
      type = lib.types.str;
    };
    month-rotate = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Month reset for network statistics";
    };
    include-mountpoint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "List of mount points to include for disk statistics";
    };
    include-nics = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "List of network interfaces to include";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.komari-agent = {
      serviceConfig.ExecStart = "${package}/bin/komari-agent -e https://top.mlyxshi.com --disable-web-ssh --disable-auto-update"
        + " -t ${cfg.token}"
        + (lib.optionalString (cfg.include-nics != null) " --include-nics ${cfg.include-nics}")
        + (lib.optionalString (cfg.include-mountpoint != null) " --include-mountpoint ${cfg.include-mountpoint}")
        + (lib.optionalString (cfg.month-rotate != null) " --month-rotate ${toString cfg.month-rotate}");
      serviceConfig.DynamicUser = true;
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };

}
