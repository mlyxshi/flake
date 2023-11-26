# https://www.youtube.com/watch?v=AvOqaeK_NaE

# hydra-create-user admin --password-prompt --role admin
# Declarative spec file: hydra.json
# Declarative input type: Git checkout
# Declarative input value: https://github.com/mlyxshi/flake.git main 
{ config, pkgs, lib, hydra, ... }:
let
  hydra-x64-publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjY+jsCfLAuMR2LP3ZqkzV5RCqSyt+lheJ7TUSRWEfv";
in
{
  sops.secrets = {
    hydra-builder-sshkey = { group = "hydra"; mode = "440"; };
    hydra-github = { group = "hydra"; mode = "440"; };
    nix-store-sign = { };
  };

  services.harmonia = {
    enable = true;
    signKeyPath = config.sops.secrets.nix-store-sign.path;
  };

  programs.ssh = {
    knownHosts = {
      "hydra-x64.mlyxshi.com".publicKey = hydra-x64-publicKey;
    };
    extraConfig = ''
      Host hydra-x64
        Hostname hydra-x64.mlyxshi.com
        User hydra-builder
        IdentityFile ${config.sops.secrets.hydra-builder-sshkey.path}
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

  nix.settings.allowed-uris = [ "https://github.com/NixOS/nixpkgs" "https://git.sr.ht/~rycee/nmd/" ];

  # turn off experimental features
  nix.settings.use-cgroups = lib.mkForce false;
  nix.settings.auto-allocate-uids = lib.mkForce false;

  services.hydra = {
    enable = true;
    package = hydra.packages.aarch64-linux.default;
    hydraURL = "http://hydra.${config.networking.domain}";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
    logo = "${pkgs.nixos-icons}/share/icons/hicolor/16x16/apps/nix-snowflake.png";
    extraConfig = ''
      include ${config.sops.secrets.hydra-github.path}
      max_output_size = ${builtins.toString (10 * 1024 * 1024 * 1024)}
      <dynamicruncommand>
        enable = 1
      </dynamicruncommand>
      <githubstatus>
        jobs = nixos:flake:.*
        excludeBuildFromContext = 1
        useShortContext = 1
      </githubstatus>
    '';
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

      http.services.hydra.loadBalancer.servers = [{
        url = "http://127.0.0.1:3000";
      }];
      # cache
      http.routers.cache = {
        rule = "Host(`cache.${config.networking.domain}`)";
        entryPoints = [ "websecure" ];
        service = "cache";
      };

      http.services.cache.loadBalancer.servers = [{
        url = "http://127.0.0.1:5000";
      }];

    };
  };

}
