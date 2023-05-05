# https://jellyfin-plugin-bangumi.pages.dev/repository.json
{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.services.backup
  ];

  backup.jellyfin = true;

  virtualisation.oci-containers.containers.jellyfin = {
    image = "ghcr.io/linuxserver/jellyfin";
    volumes = [
      "/var/lib/jellyfin:/config"
      "/var/lib/media:/var/lib/media"
    ];

    environment = {
      "PUID" = "0";
      "PGID" = "0";
    };

    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.jellyfin.rule=Host(`jellyfin.${config.networking.domain}`)"
      "traefik.http.routers.jellyfin.entrypoints=web"
    ];
  };

  systemd.services.media-init = {
    before = [ "transmission.service" "podman-jellyfin.service" ];
    unitConfig.ConditionPathExists = "!%S/media";
    serviceConfig.User = "transmission";
    serviceConfig.ExecStart = "echo"; # dummy command to make StateDirectory work
    serviceConfig.StateDirectory = "media";
    wantedBy = [ "multi-user.target" ];
  };
}
