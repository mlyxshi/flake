{ lib, ... }:
let
  ls = dir: builtins.attrNames (builtins.readDir dir);
  removeSuffix = list : map (x: lib.strings.removeSuffix ".nix" x) list;
in
{
  os = {
    darwin = import ./os/darwin;
    nixos = {
      base = import ./os/nixos/base.nix;
      desktop = import ./os/nixos/desktop.nix;
      server = import ./os/nixos/server.nix;
    };
  };

  network = import ./network;
  fileSystem = import ./fileSystem;

  settings = {
    nixConfigDir = import ./settings/nixConfigDir.nix;
    developerMode = import ./settings/developerMode.nix;
  };


  services = {
    invidious = import ./services/invidious.nix;
    libreddit = import ./services/libreddit.nix;

    shadowsocks = import ./services/shadowsocks.nix;

    prometheus = import ./services/prometheus.nix;
    telegraf = import ./services/telegraf.nix;

    ssh-config = import ./services/ssh-config.nix;
    traefik = import ./services/traefik.nix;

    tftpd = import ./services/tftpd.nix;
    hydra-aarch64 = import ./services/hydra/hydra-aarch64.nix;
    hydra-x86_64 = import ./services/hydra/hydra-x86_64.nix;

    nodestatus-client = import ./services/nodestatus-client.nix;
    miniflux = import ./services/miniflux.nix;

    transmission = import ./services/transmission;

    cache = import ./services/cache;

    backup = import ./services/backup.nix;
  };

  # container = {
  #   podman = import ./container/podman.nix;
  #   nodestatus-server = import ./container/nodestatus-server.nix;
  #   change-detection = import ./container/change-io.nix;
  #   rsshub = import ./container/rsshub.nix;
  #   vaultwarden = import ./container/vaultwarden.nix;
  #   navidrome = import ./container/navidrome.nix;
  #   jellyfin = import ./container/jellyfin.nix;
  # };

  container = lib.genAttrs removeSuffix(ls ./container) (file: import ./container/${file}.nix);

}
