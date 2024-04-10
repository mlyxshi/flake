{ pkgs, lib, config, ... }: {
  systemd.services.commit-notifier = {
    after = [ "commit-notifier-install.service" ];
    wantedBy = [ "multi-user.target" ];
    environment.RUST_LOG = "info";
    path = [ pkgs.git ];
    serviceConfig.EnvironmentFile = [ "/secret/commit-notifier" ];
    serviceConfig.ExecStart = ''
      /root/.nix-profile/bin/commit-notifier --working-dir /var/lib/commit-notifier/  --cron '0 */5 * * * *'
    '';
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

  systemd.tmpfiles.settings."10-commit-notifier" = {
    "/var/lib/commit-notifier/337000294/".d = { };
  };

}
