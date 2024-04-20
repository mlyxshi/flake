{ config, pkgs, lib, ... }: {
  
  systemd.services.qbittorrent-nox = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    serviceConfig = {
      User = "qbittorrent";
      # https://github.com/qbittorrent/qBittorrent/wiki/How-to-use-portable-mode
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --profile=/var/lib/qbittorrent-nox --relative-fastresume";
      StateDirectory = "qbittorrent-nox";
    };
    wantedBy = [ "multi-user.target" ];
  };

  users = {
    users.qbittorrent = {
      group = "qbittorrent";
      isSystemUser = true;
    };
    groups.qbittorrent = { };
  };


  virtualisation.oci-containers.containers.auto-bangumi = {
    image = "ghcr.io/estrellaxd/auto_bangumi";
    volumes = [ 
      "/var/lib/auto-bangumi/config:/app/config" 
      "/var/lib/auto-bangumi/data:/app/data" 
    ];

    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.auto-bangumi.rule=Host(`auto-bangumi.${config.networking.domain}`)"
      "traefik.http.routers.auto-bangumi.entrypoints=web"
    ];
  };

  systemd.tmpfiles.settings."10-auto-bangumi" = {
    "/var/lib/auto-bangumi/config".d = {
    };
    "/var/lib/auto-bangumi/data".d = {
    };
  };

  # systemd.services."backup-init@auto-bangumi".wantedBy = [ "multi-user.target" ];
  # systemd.services."backup-init@auto-bangumi".overrideStrategy = "asDropin";

  # systemd.services."backup@auto-bangumi".startAt = "05:00";
  # systemd.services."backup@auto-bangumi".overrideStrategy = "asDropin";
}
