{ pkgs, lib, config, ... }: {

  services.jellyfin={
    enable = true;
    user = "qbittorrent";
    group = "qbittorrent";
  };

  system.activationScripts.cloudflare-dns-sync-jellyfin = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync jellyfin.${config.networking.domain}";
  };
}