{ config, pkgs, lib, ... }: {

  users = {
    users.hydra-builder = {
      group = "hydra-builder";
      isNormalUser = true;
    };
    groups.hydra-builder = { };
  };

  users.users.hydra-builder.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbvpgAs9eKO/phjdFKrB+BeiJNl6XyrHuLyilqTgFrh" ];

  # https://github.com/NixOS/nix/issues/2789
  nix.settings.trusted-users = [ "root" "hydra-builder" ];

  system.activationScripts.cloudflare-dns-sync-hydra = {
    deps = [ "agenix" ];
    text = ''
      ${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync hydra-x64.${config.networking.domain}
    '';
  };
}
