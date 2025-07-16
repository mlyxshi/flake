{ pkgs, lib, self, config, ... }: 
let 
  package = self.packages.${config.nixpkgs.hostPlatform.system}.komari-agent;
in
{
  systemd.services."komari-agent@" = {
    after = [ "network.target" ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${package}/bin/komari-agent -e https://top.mlyxshi.com -t %i --include-nics eth0 --disable-web-ssh --disable-auto-update";
    };
  };
}
