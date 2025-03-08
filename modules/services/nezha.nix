{ pkgs, lib, config, ... }: {
  services.nezha-agent.enable = true;
  services.nezha-agent.settings.server = "130.61.171.180:8008";
  services.nezha-agent.genUuid = true;
  services.nezha-agent.settings.temperature = false;
  services.nezha-agent.debug = true;
  services.nezha-agent.clientSecretFile = "/secret/nezha";
}
