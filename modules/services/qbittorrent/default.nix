#  Run external program on torrent completion
# /run/current-system/sw/bin/qbScript "%N" "%F" "%C" "%Z" "%I" "%L"
# change password
# disable Cross-Site Request Forgery (CSRF) protection
{ pkgs, lib, config, ... }:
let
  qbScript = pkgs.writeShellScriptBin "qbScript" ''
    export DENO_DIR="/home/qbittorrent/.cache/deno"
    exec ${pkgs.deno}/bin/deno run --allow-net --allow-env ${./main.ts} $*
  '';
in
{
  age.secrets.bark-ios.file = ../../../secrets/bark-ios.age;

  users = {
    users.qbittorrent = {
      group = "qbittorrent";
      isNormalUser = true;
    };
    groups.qbittorrent = { };
  };

  environment.systemPackages = with pkgs; [
    qbittorrent-nox
    qbScript
  ];

  # https://github.com/1sixth/flakes/blob/master/modules/qbittorrent-nox.nix
  # https://github.com/qbittorrent/qBittorrent/wiki/How-to-use-portable-mode

  systemd.services.qbittorrent-nox = {
    after = [ "local-fs.target" "network-online.target" ];
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
          entryPoints = [ "web" ];
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
