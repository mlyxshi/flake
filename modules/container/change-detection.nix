{ config, pkgs, lib, ... }:
let
  service = "changeio";
in
{

  virtualisation.oci-containers.containers = {
    # "playwright-chrome" = {
    #   image = "docker.io/browserless/chrome";
    #   extraOptions = [
    #     "--label"
    #     "io.containers.autoupdate=registry"
    #   ];
    # };

    "${service}" = {
      image = "ghcr.io/dgtlmoon/changedetection.io";
      volumes = [ "/var/lib/${service}:/datastore" ];
      # dependsOn = [ "playwright-chrome" ];
      # environment = {
      #   PLAYWRIGHT_DRIVER_URL = "ws://playwright-chrome:3000/";
      # };
      extraOptions = lib.concatMap (x: [ "--label" x ]) [
        "io.containers.autoupdate=registry"
        "traefik.enable=true"
        "traefik.http.routers.${service}.rule=Host(`${service}.${config.networking.domain}`)"
        "traefik.http.routers.${service}.entrypoints=websecure"
        "traefik.http.routers.${service}.middlewares=auth@file"
      ] ++ [ "--net=host" ];
    };
  };

  systemd.services."podman-${service}".serviceConfig.StateDirectory = "${service}";
}
