{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.containers.podman
  ];

  virtualisation.oci-containers.containers.rsshub = {
    image = "ghcr.io/diygod/rsshub:chromium-bundled";
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.websecure-rsshub.rule=Host(`rss.${config.networking.domain}`)"
      "traefik.http.routers.websecure-rsshub.entrypoints=websecure"
    ];
  };
}
