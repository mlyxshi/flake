{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.containers.podman
  ];

  virtualisation.oci-containers.containers.baidunetdisk= {
    image = "docker.io/emuqi/baidunetdisk-arm64-vnc";
    volumes = [
      "/var/lib/baidunetdisk:/config"
    ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.baidunetdisk.rule=Host(`baidunetdisk.${config.networking.domain}`)"
      "traefik.http.routers.baidunetdisk.entrypoints=websecure"
      "traefik.http.routers.baidunetdisk.middlewares=auth@file"
    ];
  };
}