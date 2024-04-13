{ config, pkgs, lib, ... }: {

  virtualisation.oci-containers.containers.changedetection = {
    image = "ghcr.io/dgtlmoon/changedetection.io";
    volumes = [ "/var/lib/changedetection:/datastore" ];
    environment = { PLAYWRIGHT_DRIVER_URL = "ws://chrome-headless:3000"; };
    dependsOn = [ "chrome-headless" ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.changedetection.rule=Host(`changeio.${config.networking.domain}`)"
      "traefik.http.routers.changedetection.entrypoints=websecure"
    ];
  };

  virtualisation.oci-containers.containers.chrome-headless = {
    image = "ghcr.io/browserless/chromium";
    extraOptions = lib.concatMap (x: [ "--label" x ])
      [ "io.containers.autoupdate=registry" ];
  };

  systemd.services."backup-init@changedetection".wantedBy =
    [ "multi-user.target" ];
  systemd.services."backup-init@changedetection".overrideStrategy = "asDropin";

  systemd.services."backup@changedetection".wantedBy = [ "multi-user.target" ];
  systemd.services."backup@changedetection".startAt = "08:00";
  systemd.services."backup@changedetection".overrideStrategy = "asDropin";
}
