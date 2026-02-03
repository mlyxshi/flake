{
  config,
  pkgs,
  lib,
  ...
}:
{

  virtualisation.oci-containers.containers.commit-notifier = {
    image = "ghcr.io/mlyxshi/commit-notifier-arm64";
    volumes = [ "/var/lib/commit-notifier:/data" ];
    environmentFiles = [ /secret/commit-notifier ];
  };

  # mkdir -p /var/lib/commit-notifier/chats/696869490
  # /notifier repo-add nixpkgs https://github.com/NixOS/nixpkgs
  # /notifier repo-edit nixpkgs --branch-regex master|nixos-unstable-small
  # /notifier condition-remove nixpkgs in-master
  # /notifier condition-add —type remove-if-in-branch —expr nixos-unstable-small nixpkgs in-nixos-unstable-small
  # /notifier pr-add https://github.com/NixOS/nixpkgs/pull/476546
}
