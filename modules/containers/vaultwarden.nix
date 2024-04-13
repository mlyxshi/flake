{ config, pkgs, lib, self, ... }: {

  # https://github.com/dani-garcia/vaultwarden/pull/3304

  virtualisation.oci-containers.containers.vaultwarden = {
    image = "ghcr.io/dani-garcia/vaultwarden";
    environment = {
      SIGNUPS_ALLOWED = "false"; # Disable signups
      DOMAIN =
        "https://password.${config.networking.domain}"; # Yubikey FIDO2 WebAuthn
    };
    environmentFiles = [ "/secret/vaultwarden" ];
    volumes = [ "/var/lib/vaultwarden:/data" ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.vaultwarden.rule=Host(`password.${config.networking.domain}`)"
      "traefik.http.routers.vaultwarden.entrypoints=websecure"
    ];
  };

  systemd.services."backup-init@vaultwarden".wantedBy = [ "multi-user.target" ];
  systemd.services."backup-init@vaultwarden".overrideStrategy = "asDropin";

  systemd.services."backup@vaultwarden".wantedBy = [ "multi-user.target" ];
  systemd.services."backup@vaultwarden".startAt = "06:00";
  systemd.services."backup@vaultwarden".overrideStrategy = "asDropin";
}
