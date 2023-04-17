{ pkgs, config, ... }: {
  sops.secrets.cloudflare-dns-env = {};

  environment.systemPackages = [
    pkgs.cloudflare-dns-sync
  ];

  systemd.services.cloudflare-dns-sync-host = {
    after = [ "network-online.target" ];
    serviceConfig.ExecStart = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync  ${config.networking.fqdn}";
    wantedBy = [ "multi-user.target" ];
  };
}
