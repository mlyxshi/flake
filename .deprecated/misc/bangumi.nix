{ config, pkgs, lib, ... }: {

  sops.secrets.restic-env = { };
  sops.secrets.restic-password = { };

  # restic restore backup to create basic configuration tree directory structure

  # https://reorx.com/blog/track-and-download-shows-automatically-with-sonarr
  virtualisation.oci-containers.containers = {

    "jackett" = {
      image = "linuxserver/jackett";
      volumes = [
        "/download/jackett/config:/config"
      ];
      extraOptions = [
        "--label"
        "traefik.enable=true"

        "--label"
        "traefik.http.routers.jackett.rule=Host(`jackett.${config.networking.domain}`)"
        "--label"
        "traefik.http.routers.jackett.entrypoints=websecure"
        "--label"
        "traefik.http.routers.jackett.middlewares=auth@file"

        "--label"
        "io.containers.autoupdate=registry"
      ];
    };

    "sonarr" = {
      image = "linuxserver/sonarr";
      volumes = [
        "/download/sonarr:/data"
        "/download/sonarr/config:/config"
      ];
      environment = {
        "PUID" = "0";
        "PGID" = "0";
      };
      extraOptions = [
        "--label"
        "traefik.enable=true"

        "--label"
        "traefik.http.routers.sonarr.rule=Host(`sonarr.${config.networking.domain}`)"
        "--label"
        "traefik.http.routers.sonarr.entrypoints=websecure"
        "--label"
        "traefik.http.routers.sonarr.middlewares=auth@file"

        "--label"
        "io.containers.autoupdate=registry"
      ];
    };

    "qbittorrent" = {
      image = "linuxserver/qbittorrent";

      volumes = [
        "/download/qbittorrent/config:/config"
        "/download/sonarr:/data" #change default save path to: /data/downloads/  [hacky way: from sonarr's view, use the same download location path as qb]
      ];

      environment = {
        "PUID" = "0";
        "PGID" = "0";
      };
      extraOptions = [
        "--label"
        "traefik.enable=true"

        "--label"
        "traefik.http.routers.qbittorrent.rule=Host(`qb.media.${config.networking.domain}`)"
        "--label"
        "traefik.http.routers.qbittorrent.entrypoints=websecure"
        "--label"
        "traefik.http.routers.qbittorrent.middlewares=auth@file" #qbittorrent: Bypass authentication for clients in whitelisted IP subnets -> 0.0.0.0/0
        "--label"
        "traefik.http.services.qbittorrent.loadbalancer.server.port=8080"

        "--label"
        "io.containers.autoupdate=registry"
      ];
    };

    "jellyfin" = {
      image = "linuxserver/jellyfin";
      volumes = [
        "/download/jellyfin/config:/config"
        "/download/sonarr/media/anime:/data/anime"
      ];

      environment = {
        "PUID" = "0";
        "PGID" = "0";
      };
      extraOptions = [
        "--label"
        "traefik.enable=true"

        "--label"
        "traefik.http.routers.jellyfin.rule=Host(`jellyfin.${config.networking.domain}`)"
        "--label"
        "traefik.http.routers.jellyfin.entrypoints=websecure"

        "--label"
        "io.containers.autoupdate=registry"
      ];
    };
  };

  systemd.services.podman-jackett.environment.PODMAN_SYSTEMD_UNIT = "%n";
  systemd.services.podman-sonarr.environment.PODMAN_SYSTEMD_UNIT = "%n";
  systemd.services.podman-qbittorrent.environment.PODMAN_SYSTEMD_UNIT = "%n";
  systemd.services.podman-jellyfin.environment.PODMAN_SYSTEMD_UNIT = "%n";

  system.activationScripts.cloudflare-dns-sync-bangumi = {
    deps = [ "setupSecrets" ];
    text = ''
      ${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync jackett.${config.networking.domain}
      ${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync sonarr.${config.networking.domain}
      ${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync qb.media.${config.networking.domain}
      ${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync jellyfin.${config.networking.domain}
    '';
  };

  services.restic.backups."media" = {
    environmentFile = config.sops.secrets.restic-env.path;
    passwordFile = config.sops.secrets.restic-password.path;
    extraBackupArgs = [
      "--exclude=sonarr/downloads/*" # * keep directory
      "--exclude=sonarr/media/anime/*"
    ];
    paths = [ "/download" ];
    timerConfig.OnCalendar = "02:00";
    pruneOpts = [ "--keep-last 2" ];
  };
}
