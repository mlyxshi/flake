{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.services.backup
  ];
  backup.vaultwarden = true;

  virtualisation.oci-containers.containers.vaultwarden = {
    image = "ghcr.io/dani-garcia/vaultwarden";
    environment = {
      SIGNUPS_ALLOWED = "false"; # Disable signups
      DOMAIN = "https://password.${config.networking.domain}"; # Yubikey FIDO2 WebAuthn
      WEBSOCKET_ENABLED = "true"; # Websockets: real-time sync of data between server and clients (only browser and desktop Bitwarden clients)
    };
    volumes = [
      "/var/lib/vaultwarden:/data"
    ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"

      "traefik.http.routers.vaultwarden.rule=Host(`password.${config.networking.domain}`)"
      "traefik.http.routers.vaultwarden.service=vaultwarden"
      "traefik.http.routers.vaultwarden.entrypoints=websecure"

      "traefik.http.routers.vaultwarden-websocket.rule=Host(`password.${config.networking.domain}`) && Path(`/notifications/hub`)"
      "traefik.http.routers.vaultwarden-websocket.service=vaultwarden-websocket"
      "traefik.http.routers.vaultwarden-websocket.entrypoints=websecure"

      "traefik.http.services.vaultwarden.loadbalancer.server.port=80"
      "traefik.http.services.vaultwarden-websocket.loadbalancer.server.port=3012"
    ] ++ [ "--no-healthcheck" ];
  };
}
