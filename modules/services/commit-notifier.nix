{ pkgs, lib, config, ... }: {
  systemd.services.commit-notifier = {
    after = [ "commit-notifier-install.service" ];
    wantedBy = [ "multi-user.target" ];
    environment.RUST_LOG = "info";
    serviceConfig.EnvironmentFile = [ "/secret/commit-notifier" ];
    script = ''
      mkdir -p /var/lib/commit-notifier/337000294
      /root/.nix-profile/bin/commit-notifier --working-dir /var/lib/commit-notifier/  --cron '0 */5 * * * *'
    '';
    serviceConfig.StateDirectory = "commit-notifier";
  };

  # Too many flake input will add to my config if add linyinfeng/commit-notifier to my config
  # Just install it without affecting my config (bad way)
  systemd.services.commit-notifier-install = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = "!/root/.nix-profile/bin/commit-notifier";
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart =
      "/run/current-system/sw/bin/nix profile install github:linyinfeng/commit-notifier#commit-notifier";
  };
}
