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
    # https://github.com/NixOS/nix/pull/4938
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

  # turn off experimental features
  nix.settings.use-cgroups = lib.mkForce false;
  nix.settings.auto-allocate-uids = lib.mkForce false;

  services.hydra = {
    enable = true;
    package = hydra.packages.aarch64-linux.default;
    hydraURL = "http://hydra.${config.networking.domain}";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [ "/etc/nix/machines" ];
    useSubstitutes = true;
    logo = "${pkgs.nixos-icons}/share/icons/hicolor/16x16/apps/nix-snowflake.png";
    extraConfig = ''
      include ${config.sops.secrets.hydra-github.path}
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
      http = {
        routers.hydra = {
          rule = "Host(`hydra.${config.networking.domain}`)";
          entryPoints = [ "web" ];
          service = "hydra";
        };

        services.hydra.loadBalancer.servers = [{
          url = "http://127.0.0.1:3000";
        }];
      };
    };
  };

}
