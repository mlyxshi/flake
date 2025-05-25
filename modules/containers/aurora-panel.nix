{ config, pkgs, lib, ... }: {

  # virtualisation.oci-containers.containers.changedetection = {
  #   image = "ghcr.io/dgtlmoon/changedetection.io";
  #   volumes = [ "/var/lib/changedetection:/datastore" ];
  #   environment = { PLAYWRIGHT_DRIVER_URL = "ws://chrome-headless:3000"; };
  #   dependsOn = [ "chrome-headless" ];
  #   extraOptions = lib.concatMap (x: [ "--label" x ]) [
  #     "io.containers.autoupdate=registry"
  #     "traefik.enable=true"
  #     "traefik.http.routers.changedetection.rule=Host(`changeio.${config.networking.domain}`)"
  #     "traefik.http.routers.changedetection.entrypoints=websecure"
  #   ];
  # };

  virtualisation.oci-containers.containers.postgres = {
    image = "quay.io/postgres:13-alpine";
    environment = {
      POSTGRES_USER = "aurora";
      POSTGRES_PASSWORD = "AuroraAdminPanel321";
      POSTGRES_DB = "aurora";
    };
    volumes = [ "/var/lib/aurora/postgresql:/var/lib/postgresql/data" ];
  };

  virtualisation.oci-containers.containers.redis = {
    image = "quay.io/redis:8-alpine";
  };

}
