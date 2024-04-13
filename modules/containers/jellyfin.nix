# https://jellyfin-plugin-bangumi.pages.dev/repository.json
{ config, pkgs, lib, self, ... }: {

  imports = [ self.nixosModules.containers.podman ];

  virtualisation.oci-containers.containers.jellyfin = {
    image = "ghcr.io/linuxserver/jellyfin";
    volumes = [ "/var/lib/jellyfin:/config" "/var/lib/media:/var/lib/media" ];

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

  #  Transmission will download anime to /var/lib/media
  systemd.tmpfiles.settings."10-transmission" = {
    "/var/lib/media/".d = {
      user = "transmission";
      group = "transmission";
    };
  };


  systemd.services."backup-init@jellyfin".wantedBy = [ "multi-user.target" ];
  systemd.services."backup-init@jellyfin".overrideStrategy = "asDropin";

  systemd.services."backup@jellyfin".wantedBy = [ "multi-user.target" ];
  systemd.services."backup@jellyfin".overrideStrategy = "asDropin";
}
