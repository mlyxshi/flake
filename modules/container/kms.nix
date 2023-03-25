#public port 1688
{ config, pkgs, lib, ... }:
let
  service = "kms";
in
{
  virtualisation.oci-containers.containers = {
    "${service}" = {
      image = "docker.io/mikolatero/vlmcsd";
      extraOptions = lib.concatMap (x: [ "--label" x ]) [
        "io.containers.autoupdate=registry"
        "traefik.enable=true"
        "traefik.http.routers.${service}.rule=Host(`${service}.${config.networking.domain}`)"
        "traefik.http.routers.${service}.entrypoints=web"
      ];
    };
  };

  system.activationScripts."cloudflare-dns-sync-${service}" = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync ${service}.${config.networking.domain}";
  };

}

# Windows 10 LTSC 2021
# Install product key
#slmgr.vbs /ipk M7XTQ-FN8P6-TTKYV-9D4CC-J462D
# Specifies KMS host
#slmgr.vbs /skms kms.mlyxshi.com
# Prompts KMS activation attempt.
#slmgr.vbs /ato
# Display detailed license information.
#slmgr.vbs -dlv
