{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.containers.podman
  ];

  backup.changedetection = true;

  virtualisation.oci-containers.containers.changedetection = {
    image = "ghcr.io/dgtlmoon/changedetection.io";
    volumes = [
      "/var/lib/changedetection:/datastore"
    ];
    environment = {
      PLAYWRIGHT_DRIVER_URL = "ws://chrome-headless:3000";
    };
    dependsOn = [
      "chrome-headless"
    ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.changedetection.rule=Host(`changeio.${config.networking.domain}`)"
      "traefik.http.routers.changedetection.entrypoints=websecure"
    ];
  };

  virtualisation.oci-containers.containers.chrome-headless = {
    image = "ghcr.io/browserless/chrome";
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
    ];
  };
}
