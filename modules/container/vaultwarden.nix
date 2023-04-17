{ config, pkgs, lib, ... }: {

  sops.secrets.restic-env = { };

  virtualisation.oci-containers.containers = {
    "vaultwarden" = {
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
  };

  systemd.services.vaultwarden-data-init = {
    after = [ "network-online.target" ];
    before = [ "podman-vaultwarden.service" ];
    unitConfig.ConditionPathExists = "!%S/vaultwarden";
    environment.RESTIC_CACHE_DIR = "%C/restic";
    serviceConfig.EnvironmentFile = config.sops.secrets.restic-env.path;
    serviceConfig.ExecSearchPath = "${pkgs.restic}/bin";
    serviceConfig.ExecStart = "restic restore latest --path %S/vaultwarden  --target /";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.vaultwarden-backup = {
    environment.RESTIC_CACHE_DIR = "%C/restic";
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = config.sops.secrets.restic-env.path;
      ExecSearchPath = "${pkgs.restic}/bin";
      ExecStart = [
        "restic backup %S/vaultwarden"
        "restic forget --prune --keep-last 2"
        "restic check"
      ];
    };
    startAt = "06:00";
  };

  system.activationScripts.cloudflare-dns-sync-vaultwarden = {
    deps = [ "setupSecrets" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync password.${config.networking.domain}";
  };

}
