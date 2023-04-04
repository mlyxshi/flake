# change password
{ pkgs, lib, config, ... }: 
let
  pre-config = pkgs.writeText "pre-config" ''
    [AutoRun]
    enabled=true
    program=program=/run/current-system/sw/bin/deno run --allow-net --allow-env /etc/qbScript \"%N\" \"%F\" \"%C\" \"%Z\" \"%I\" \"%L\"
    
    [Preferences]
    WebUI\CSRFProtection=false
  '';
in
{
  age.secrets.bark-ios.file = ../../../secrets/bark-ios.age;

  users = {
    users.qbittorrent = {
      group = "qbittorrent";
      isSystemUser = true;
    };
    groups.qbittorrent = { };
  };

  environment.systemPackages = with pkgs; [
    deno
    qbittorrent-nox
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
    preStart = ''
      mkdir -p /var/lib/qbittorrent-nox/qBittorrent/config/
      touch /var/lib/qbittorrent-nox/qBittorrent/config/qBittorrent.conf
      ${pkgs.crudini}/bin/crudini --merge /var/lib/qbittorrent-nox/qBittorrent/config/qBittorrent.conf < ${pre-config}
    '';
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.bangumi-index = {
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.deno}/bin/deno run --allow-net --allow-read https://deno.land/std/http/file_server.ts  %S/qbittorrent-nox/qBittorrent/downloads/";
    };
    wantedBy = [ "multi-user.target" ];
  };


  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.qbittorrent-nox = {
          rule = "Host(`qb.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "qbittorrent-nox";
        };

        services.qbittorrent-nox.loadBalancer.servers = [{
          url = "http://127.0.0.1:8080";
        }];


        routers.bangumi-index = {
          rule = "Host(`bangumi-index.${config.networking.domain}`)";
          entryPoints = [ "web" ];
          service = "bangumi-index";
        };

        services.bangumi-index.loadBalancer.servers = [{
          url = "http://127.0.0.1:4507";
        }];
      };
    };
  };

  system.activationScripts.cloudflare-dns-sync-qbittorrent-nox = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync qb.${config.networking.domain} bangumi-index.${config.networking.domain}";
  };
}
