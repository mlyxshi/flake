{ pkgs, lib, config, ... }: {

  virtualisation.oci-containers.containers = {
    "auto-bangumi" = {
      image = "docker.io/estrellaxd/auto_bangumi";
      volumes = [
        "/var/lib/auto-bangumi:/config"
      ];
      environment = {
        "PUID" = "1000";
        "PGID" = "1000";
        "AB_RSS"="https://mikanani.me/RSS/MyBangumi?token=WX0iAPimfeV8TL5%2f4RHdvw%3d%3d";
        "AB_INTERVAL_TIME"="60";
        "AB_DOWNLOAD_PATH"="/var/lib/qbittorrent-nox/qBittorrent/downloads/bangumi";
      };
      extraOptions = [
        "--label"
        "io.containers.autoupdate=registry"
        "--net=host"
      ];
    };

    "jellyfin" = {
      image = "ghcr.io/linuxserver/jellyfin";
      volumes = [
        "/var/lib/jellyfin/:/config"
        "/var/lib/qbittorrent-nox/qBittorrent/downloads/bangumi/:/data/bangumi"
      ];
      environment = {
        "PUID" = "1000";
        "PGID" = "1000";
      };
      extraOptions = lib.concatMap (x: [ "--label" x ]) [
        "io.containers.autoupdate=registry"
        "traefik.enable=true"
        "traefik.http.routers.jellyfin.rule=Host(`jellyfin.${config.networking.domain}`)"
        "traefik.http.routers.jellyfin.entrypoints=websecure"
      ];
    };
  };

  systemd.services.podman-auto-bangumi.serviceConfig.StateDirectory = "auto-bangumi";
  systemd.services.podman-auto-bangumi.after = [ "qbittorrent-nox.service" ];

  systemd.services.podman-jellyfin.serviceConfig.StateDirectory = "jellyfin";
  systemd.services.podman-jellyfin.after = [ "qbittorrent-nox.service" ];

  system.activationScripts.cloudflare-dns-sync-jellyfin = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync jellyfin.${config.networking.domain}";
  };

}
