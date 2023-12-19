{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.containers.podman
  ];

  virtualisation.oci-containers.containers.rsshub = {
    image = "ghcr.io/matrix-org/matrix-viewer";
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.websecure-matrix.rule=Host(`matrix.${config.networking.domain}`)"
      "traefik.http.routers.websecure-matrix.entrypoints=websecure"
    ];
  };
}
