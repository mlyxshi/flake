{lib}:
let
  ls = dir: builtins.attrNames (builtins.readDir dir);
  pureName = pathList: map(path: if lib.strings.hasSuffix ".nix" path then lib.strings.removeSuffix ".nix" path else path) pathList;
  importPath = path: if lib.sources.pathIsDirectory path then path else "${path}.nix";
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

  # services = {
  #   invidious = import ./services/invidious.nix;
  #   libreddit = import ./services/libreddit.nix;

  #   shadowsocks = import ./services/shadowsocks.nix;

  #   prometheus = import ./services/prometheus.nix;
  #   telegraf = import ./services/telegraf.nix;

  #   ssh-config = import ./services/ssh-config.nix;
  #   traefik = import ./services/traefik.nix;

  #   tftpd = import ./services/tftpd.nix;
  #   hydra-aarch64 = import ./services/hydra/hydra-aarch64.nix;
  #   hydra-x86_64 = import ./services/hydra/hydra-x86_64.nix;

  #   nodestatus-client = import ./services/nodestatus-client.nix;
  #   miniflux = import ./services/miniflux.nix;

  #   transmission = import ./services/transmission;

  #   cache = import ./services/cache;

  #   backup = import ./services/backup.nix;
  # };

  network = import ./network;
  fileSystem = import ./fileSystem;
  settings =  lib.genAttrs (pureName(ls ./settings)) (file: import ./settings/${file}.nix);
  container = lib.genAttrs (pureName(ls ./container)) (file: import ./container/${file}.nix);
  services = lib.genAttrs (pureName(ls ./services)) (file: import (importPath ./services/${file}) );
}
