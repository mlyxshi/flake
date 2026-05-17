{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
{

  # imports = [
  #   self.nixosModules.programs.vscode-ssh-remote
  # ];

  systemd.services.komari-agent.environment.AGENT_ENDPOINT = "http://138.2.16.45";
  systemd.services.komari-agent.environment.AGENT_CUSTOM_IPV4 = "35.212.172.97";
}
