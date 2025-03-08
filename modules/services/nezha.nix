{ pkgs, lib, config, ... }: {
  services.nezha-agent.enable = true;
  services.nezha-agent.settings.server = "top.mlyxshi.com:8008";
  services.nezha-agent.genUuid = true;
}
