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
    qbittorrent = import ./services/qbittorrent.nix;

    prometheus = import ./services/prometheus.nix;
    telegraf = import ./services/telegraf.nix;

    ssh-config = import ./services/ssh-config.nix;
    traefik = import ./services/traefik.nix;
    cloudflare-dns-sync = import ./services/cloudflare-dns-sync.nix;
    tftpd = import ./services/tftpd.nix;
    hydra-aarch64 = import ./services/hydra/hydra-aarch64.nix;
    hydra-x86_64 = import ./services/hydra/hydra-x86_64.nix;

    nodestatus-client = import ./services/nodestatus-client.nix;
    miniflux = import ./services/miniflux.nix;

    transmission = import ./services/transmission;
  };

  container = {
    podman = import ./container/podman.nix;
    nodestatus-server = import ./container/nodestatus-server;
    change-detection = import ./container/change-detection.nix;
    kms = import ./container/kms.nix;
    rsshub = import ./container/rsshub.nix;
    vaultwarden = import ./container/vaultwarden.nix;
  };

}
