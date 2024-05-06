# /notifier repo-add nixpkgs https://github.com/NixOS/nixpkgs
# /notifier repo-edit nixpkgs —branch-regex "master|nixos-unstable|nixos-unstable-small"
# /notifier condition-add nixpkgs in-nixos-unstable —type in-branch —expr nixos-unstable
{ pkgs, lib, config, ... }: {
  systemd.services.commit-notifier = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment.RUST_LOG = "info";
    path = [ pkgs.git ];
    serviceConfig.EnvironmentFile = [ "/secret/commit-notifier" ];
    serviceConfig.ExecStart = ''
      ${pkgs.commit-notifier}/bin/commit-notifier --working-dir /var/lib/commit-notifier/  --cron '0 */5 * * * *'
    '';
  };

  systemd.tmpfiles.settings."10-commit-notifier" = {
    "/var/lib/commit-notifier/337000294/".d = { };
  };

}
