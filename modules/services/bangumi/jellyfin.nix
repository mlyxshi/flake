{ pkgs, lib, config, ... }: {

  # systemd.services.jellyfin.after = [ "qbittorrent-nox.service" ];
  
  system.activationScripts.cloudflare-dns-sync-jellyfin = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync jellyfin.${config.networking.domain}";
  };
}