# https://www.youtube.com/watch?v=AvOqaeK_NaE

# hydra-create-user admin --password-prompt --role admin
# Declarative spec file: hydra.json
# Declarative input type: Git checkout
# Declarative input value: https://github.com/mlyxshi/flake.git main 
{ config, pkgs, lib, ... }:
let
  hydra-x64-publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4L1uoDAKu/rwY1ig0PAh8qHPdPzFx6CGDsn8Svs0X1";
in
{

  programs.ssh = {
    knownHosts = { "hydra-x64.mlyxshi.com".publicKey = hydra-x64-publicKey; };
    extraConfig = ''
      Host hydra-x64
        Hostname hydra-x64.mlyxshi.com
        User hydra-builder
        IdentityFile /secret/ssh/hydra-x64

      Host tmp-install
        HostName tmp-install.mlyxshi.com
        User root
        ProxyCommand ${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h
        StrictHostKeyChecking no
        IdentityFile /secret/ssh/github
    '';
  };

  nix.buildMachines = [
    # https://github.com/NixOS/hydra/issues/433#issuecomment-321212080
    {
      hostName = "localhost";
      systems = [ "aarch64-linux" ];
      maxJobs = 4;
      supportedFeatures = [ "nixos-test" "big-parallel" "benchmark" ];
    }
    {
      hostName = "hydra-x64";
      systems = [ "x86_64-linux" ];
      maxJobs = 4;
      supportedFeatures = [ "nixos-test" "big-parallel" "benchmark" ];
    }
  ];

  nix.settings.allowed-uris = "github:";

  # turn off experimental features
  nix.settings.use-cgroups = lib.mkForce false;
  nix.settings.auto-allocate-uids = lib.mkForce false;

  services.hydra = {
    enable = true;
    hydraURL = "http://hydra.${config.networking.domain}";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
  };

  # https://github.com/NixOS/hydra/issues/1186
  systemd.services.hydra-evaluator.environment.GC_DONT_GC = "true";

  services.traefik = {
    dynamicConfigOptions = {
      # hydra
      http.routers.hydra = {
        rule = "Host(`hydra.${config.networking.domain}`)";
        entryPoints = [ "web" ];
        service = "hydra";
      };

      http.services.hydra.loadBalancer.servers =
        [{ url = "http://127.0.0.1:3000"; }];
      # cache
      # http.routers.cache = {
      #   rule = "Host(`cache.${config.networking.domain}`)";
      #   entryPoints = [ "websecure" ];
      #   service = "cache";
      # };

      # http.services.cache.loadBalancer.servers = [{
      #   url = "http://127.0.0.1:5000";
      # }];
    };
  };
}
