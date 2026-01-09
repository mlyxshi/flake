{
  self,
  config,
  pkgs,
  lib,
  ...
}:
{

  nixpkgs.overlays = [
    (final: prev: {
      commit-notifier = prev.callPackage (self + "/pkgs/commit-notifier.nix") { };
    })
  ];

# mkdir -p /data/chats/696869490
# /notifier repo-add nixpkgs https://github.com/NixOS/nixpkgs
# /notifier repo-edit nixpkgs --branch-regex master|nixos-unstable|nixos-unstable-small
# /notifier condition-add —type remove-if-in-branch —expr nixos-unstable nixpkgs in-nixos-unstable
# /notifier pr-add https://github.com/NixOS/nixpkgs/pull/476546

  systemd.services.commit-notifier = {
    path = [
      pkgs.git
    ];
    environment = {
      RUST_LOG = "info";
    };
    preStart = "mkdir -p /var/lib/commit-notifier/chats/696869490";
    serviceConfig.ExecStart = "${pkgs.commit-notifier}/bin/commit-notifier --working-dir /var/lib/commit-notifier  --cron "0 * * * * *"   --admin-chat-id=696869490";
    serviceConfig.StateDirectory = "commit-notifier";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };

}
