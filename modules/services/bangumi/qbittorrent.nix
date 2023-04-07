# change password

{ pkgs, lib, config, ... }: 
let
  # send notification to bark(iOS)
  # seed 7 days then delete
  # disable CSRF Protection
  pre-config = pkgs.writeText "pre-config" ''
    [AutoRun]
    enabled=true
    program=/run/current-system/sw/bin/deno run --allow-net --allow-env /etc/qbScript \"%N\" \"%F\" \"%C\" \"%Z\" \"%I\" \"%L\"
    
    [BitTorrent]
    Session\GlobalMaxSeedingMinutes=10080
    Session\MaxRatioAction=3

    [Preferences]
    WebUI\CSRFProtection=false
  '';
in
{
  age.secrets.bark-ios.file = ../../../secrets/bark-ios.age;

  users = {
    users.qbittorrent = {
      group = "qbittorrent";
      isNormalUser = true;
      uid = 1000;
    };
    groups.qbittorrent = { 
      gid = 1000;
    };
  };

  environment.systemPackages = with pkgs; [
    deno
  ];

  environment.etc."qbScript".source = ./main.ts;

  # https://github.com/qbittorrent/qBittorrent/wiki/How-to-use-portable-mode
  systemd.services.qbittorrent-nox = {
    after = [ "local-fs.target" "network-online.target" ];
    environment = {
      DENO_DIR = "%S/qbittorrent-nox/.deno";
    };
    serviceConfig = {
      User = "qbittorrent";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --profile=%S/qbittorrent-nox --relative-fastresume";
      StateDirectory = "qbittorrent-nox";
      EnvironmentFile = [
        config.age.secrets.bark-ios.path
      ];
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.qbittorrent-nox-config-init = {
    before = [ "qbittorrent-nox.service" ];
    unitConfig.ConditionPathExists = "!%S/qbittorrent-nox/qBittorrent/config/qBittorrent.conf";
    serviceConfig.User = "qbittorrent";
    serviceConfig.StateDirectory = "qbittorrent-nox";
    script = ''
      mkdir -p /var/lib/qbittorrent-nox/qBittorrent/config
      mkdir -p /var/lib/qbittorrent-nox/qBittorrent/downloads/bangumi
      cat ${pre-config} > /var/lib/qbittorrent-nox/qBittorrent/config/qBittorrent.conf
    '';
    wantedBy = [ "multi-user.target" ];
  };

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.qbittorrent-nox = {
          rule = "Host(`qbittorrent-bangumi.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "qbittorrent-nox";
        };

        services.qbittorrent-nox.loadBalancer.servers = [{
          url = "http://127.0.0.1:8080";
        }];
      };
    };
  };

  system.activationScripts.cloudflare-dns-sync-qbittorrent-nox = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync qbittorrent-bangumi.${config.networking.domain}";
  };
}