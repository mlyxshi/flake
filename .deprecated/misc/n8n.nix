{ config, pkgs, lib, ... }: {

  virtualisation.oci-containers.containers = {
    "n8n" = {
      image = "docker.io/n8nio/n8n ";
      volumes = [
        "/var/lib/n8n:/home/node/.n8n"
      ];
      extraOptions = [
        "--label"
        "traefik.enable=true"

        "--label"
        "traefik.http.routers.n8n.rule=Host(`n8n.${config.networking.domain}`)"
        "--label"
        "traefik.http.routers.n8n.entrypoints=websecure"
        "--label"
        "traefik.http.routers.n8n.middlewares=auth@file"

        "--label"
        "io.containers.autoupdate=registry"
      ];
    };
  };

  systemd.services.podman-n8n.serviceConfig.StateDirectory = "n8n";

  system.activationScripts.cloudflare-dns-sync-n8n = {
    deps = [ "setupSecrets" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync n8n.${config.networking.domain}";
  };

}
