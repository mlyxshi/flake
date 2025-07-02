{ pkgs, lib, self, config, ... }: 
let 
  package = self.packages.${config.nixpkgs.hostPlatform.system}.komari-agent;
in
{
  systemd.services."komari-agent@" = {
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${package}/bin/komari-agent -e https://komari.mlyxshi.com --disable-web-ssh --disable-auto-update -t %i";
    };
  };
}
