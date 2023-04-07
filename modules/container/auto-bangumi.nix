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
        "AB_RSS" = "https://mikanani.me/RSS/MyBangumi?token=WX0iAPimfeV8TL5%2f4RHdvw%3d%3d";
        "AB_INTERVAL_TIME" = "60";
        "AB_DOWNLOAD_PATH" = "/var/lib/qbittorrent-nox/qBittorrent/downloads/bangumi";
      };
      extraOptions = [
        "--label"
        "io.containers.autoupdate=registry"
        "--net=host"
      ];
    };
  };

  systemd.services.podman-auto-bangumi.serviceConfig.StateDirectory = "auto-bangumi";
  systemd.services.podman-auto-bangumi.after = [ "qbittorrent-nox.service" ];
}
