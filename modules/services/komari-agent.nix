{ pkgs, lib, self, config, ... }:
let
  package = self.packages.${config.nixpkgs.hostPlatform.system}.komari-agent;
in
{
  systemd.services.komari-agent = {
    environment = {
      AGENT_ENDPOINT = "https://top.mlyxshi.com";
      AGENT_DISABLE_AUTO_UPDATE = "true";
      AGENT_DISABLE_WEB_SSH = "true";
      AGENT_CONFIG_FILE = "/secret/komari/${config.networking.hostName}"; #token
    };
    serviceConfig.ExecStart = "${package}/bin/komari-agent";
    serviceConfig.DynamicUser = true;
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };
}
