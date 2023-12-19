{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.containers.podman
  ];

  virtualisation.oci-containers.containers.matrix-viewer = {
    image = "ghcr.io/matrix-org/matrix-viewer/matrix-viewer:sha-5c448f24c252ebc4068824f1e1e47cefe7527b5f";
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.websecure-matrix.rule=Host(`matrix.${config.networking.domain}`)"
      "traefik.http.routers.websecure-matrix.entrypoints=websecure"
    ];
  };
}
