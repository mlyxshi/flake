{ config, pkgs, lib, ... }: {

  virtualisation.oci-containers.containers = {
    "rsshub" = {
      image = "ghcr.io/diygod/rsshub";
      extraOptions = lib.concatMap (x: [ "--label" x ]) [
        "io.containers.autoupdate=registry"
        "traefik.enable=true"
        "traefik.http.routers.websecure-rsshub.rule=Host(`rss.${config.networking.domain}`)"
        "traefik.http.routers.websecure-rsshub.entrypoints=websecure"
      ];
    };
  };

  system.activationScripts.cloudflare-dns-sync-rsshub = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync rss.${config.networking.domain}";
  };
}
