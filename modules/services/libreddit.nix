{ config, pkgs, lib, ... }: {

  systemd.services.libreddit = {
    after = [ "network.target" ];
    environment = {
      LIBREDDIT_DEFAULT_WIDE = "on";
      LIBREDDIT_DEFAULT_SHOW_NSFW = "on";
      LIBREDDIT_DEFAULT_USE_HLS = "on";
    };
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${pkgs.libreddit}/bin/libreddit  --port 8888 --address 127.0.0.1";
    };
    wantedBy = [ "multi-user.target" ];
  };


  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.libreddit = {
          rule = "Host(`reddit.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "libreddit";
        };

        services.libreddit.loadBalancer.servers = [{
          url = "http://127.0.0.1:8888";
        }];
      };
    };
  };

  system.activationScripts.cloudflare-dns-sync-libre = {
    deps = [ "setupSecrets" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync reddit.${config.networking.domain}";
  };
}
