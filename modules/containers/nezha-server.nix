{ pkgs, lib, config, ... }: {

  virtualisation.oci-containers.containers.nezha-server = {
    image = "ghcr.io/nezhahq/nezha";
    volumes = [ "/var/lib/nezha-server:/dashboard/data" ];
    ports = [ "8008:8008" ];
    environment = {
    };
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.nezha.rule=Host(`top.${config.networking.domain}`)"
      "traefik.http.routers.nezha.entrypoints=web"
    ];
  };

  systemd.services."backup-init@nezha-server".wantedBy = [ "multi-user.target" ];
  systemd.services."backup-init@nezha-server".overrideStrategy = "asDropin";

  systemd.services."backup@nezha-server".startAt = "04:00";
  systemd.services."backup@nezha-server".overrideStrategy = "asDropin";
}
