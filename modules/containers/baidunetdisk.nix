{ config, pkgs, lib, self, ... }: {

  imports = [ self.nixosModules.containers.podman ];

  virtualisation.oci-containers.containers.baidunetdisk = {
    image = "docker.io/emuqi/baidunetdisk-arm64-vnc";
    volumes = [ "/var/lib/baidunetdisk:/config" ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.baidunetdisk.rule=Host(`baidunetdisk.${config.networking.domain}`)"
      "traefik.http.routers.baidunetdisk.entrypoints=websecure"
      "traefik.http.routers.baidunetdisk.middlewares=auth@file"
    ];
  };

  services..enable = true;
  services.caddy.virtualHosts.":8020".extraConfig = ''
    root * /var/lib/baidunetdisk
    file_server browse {
      hide log xdg .config .pki
    }
  '';

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.baidunetdisk-index = {
          rule = "Host(`baidunetdisk-index.${config.networking.domain}`)";
          entryPoints = [ "web" ];
          service = "baidunetdisk-index";
        };

        services.baidunetdisk-index.loadBalancer.servers =
          [{ url = "http://127.0.0.1:8020"; }];
      };
    };
  };
}
