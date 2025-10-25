{ config, pkgs, lib, utils, self, ... }:
let
  # sing-box-latest = self.packages.${config.nixpkgs.hostPlatform.system}.sing-box;

  pythonEnv = pkgs.python3.withPackages (ps: with ps; [ python-telegram-bot ]);
in
{

  imports = [
    self.nixosModules.services.cloudflare-warp
  ];

  services.sing-box.enable = true;
  services.sing-box.settings =  import ./sing-box-config.nix;

  # TG bot
  systemd.services.traffic-tg = {
    serviceConfig = {
      ExecStart = "${pythonEnv}/bin/python ${./traffic-tg.py}";
    };
    wantedBy = [ "multi-user.target" ];
  };

}
