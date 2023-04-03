{ config, pkgs, lib, ... }: {

  systemd.services.alist = {
    after = [ "network.target" ];
    # environment = {
    #   LIBREDDIT_DEFAULT_WIDE = "on";
    #   LIBREDDIT_DEFAULT_SHOW_NSFW = "on";
    #   LIBREDDIT_DEFAULT_USE_HLS = "on";
    # };
    serviceConfig = {
      # DynamicUser = true;
      ExecStart = "${pkgs.alist}/bin/alist server";
    };
    wantedBy = [ "multi-user.target" ];
  };


  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.alist = {
          rule = "Host(`alist.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "alist";
        };

        services.alist.loadBalancer.servers = [{
          url = "http://127.0.0.1:5244";
        }];
      };
    };
  };

  system.activationScripts.cloudflare-dns-sync-alist = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync alist.${config.networking.domain}";
  };
}