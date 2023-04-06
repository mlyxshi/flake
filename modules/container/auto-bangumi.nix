{ pkgs, lib, config, ... }: {

   age.secrets.autobangumi-env.file = ../../secrets/autobangumi-env.age;

  virtualisation.oci-containers.containers = {
    "auto-bangumi" = {
      image = "docker.io/estrellaxd/auto_bangumi";
      volumes = [
        "/var/lib/auto-bangumi:/config"
      ];
      environment = {
        "PUID" = "1000";
        "PGID" = "1000";
        "AB_DOWNLOADER_USERNAME"="admin";
        "AB_DOWNLOADER_HOST"="127.0.0.1:8080";
      };
      environmentFiles = [
        config.age.secrets.autobangumi-env.path
      ];
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
