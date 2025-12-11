{
  pkgs,
  lib,
  self,
  config,
  ...
}:
{
  systemd.services.komari-agent = {
    environment = {
      AGENT_ENDPOINT = "https://top.mlyxshi.com";
      AGENT_DISABLE_AUTO_UPDATE = "true";
      AGENT_DISABLE_WEB_SSH = "true";
      AGENT_MONTH_ROTATE = lib.mkDefault "1";
      AGENT_CONFIG_FILE = "/secret/komari/${config.networking.hostName}"; # token
    };
    serviceConfig.ExecStart = lib.mkDefault "${pkgs.komari-agent}/bin/komari-agent";
    serviceConfig.DynamicUser = true;
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };
}
