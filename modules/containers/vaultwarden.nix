{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.services.backup
  ];

  backup.vaultwarden = true;

  # https://github.com/dani-garcia/vaultwarden/pull/3304
  sops.secrets."vaultwarden/id" = { };
  sops.secrets."vaultwarden/key" = { };
  sops.templates.vaultwarden.content = ''
    PUSH_ENABLED=true
    PUSH_INSTALLATION_ID=${config.sops.placeholder."vaultwarden/id"}
    PUSH_INSTALLATION_KEY=${config.sops.placeholder."vaultwarden/key"}
  '';

  virtualisation.oci-containers.containers.vaultwarden = {
    image = "ghcr.io/dani-garcia/vaultwarden";
    environment = {
      SIGNUPS_ALLOWED = "false"; # Disable signups
      DOMAIN = "https://password.${config.networking.domain}"; # Yubikey FIDO2 WebAuthn
    };
    environmentFiles = [
      config.sops.templates.vaultwarden.path
    ];
    volumes = [
      "/var/lib/vaultwarden:/data"
    ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.vaultwarden.rule=Host(`password.${config.networking.domain}`)"
      "traefik.http.routers.vaultwarden.entrypoints=websecure"
    ] ++ [ "--no-healthcheck" ];
  };
}
