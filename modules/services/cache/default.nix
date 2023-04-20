# https://medium.com/earlybyte/the-s3-nix-cache-manual-e320da6b1a9b
# https://nixos.org/manual/nix/stable/package-management/s3-substituter.html
# https://fzakaria.github.io/nix-http-binary-cache-api-spec/
{ pkgs, lib, config, ... }: {

  sops.secrets.user = { };
  sops.secrets.password = { };
  sops.templates.minio-root-credentials.content = ''
    MINIO_ROOT_USER=${config.sops.placeholder.user}
    MINIO_ROOT_PASSWORD=${config.sops.placeholder.password}
  '';

  users = {
    users.minio = {
      group = "minio";
      isSystemUser = true;
    };
    groups.minio = { };
  };

  systemd.services.minio = {
    after = [ "network-online.target" ];
    environment = {
      HOME = "%S/minio";
      MINIO_SERVER_URL = "https://minio.${config.networking.domain}";
      MINIO_BROWSER_REDIRECT_URL = "https://minio-dashboard.${config.networking.domain}";
    };
    serviceConfig.User = "minio";
    serviceConfig.EnvironmentFile = config.sops.templates.minio-root-credentials.path;
    serviceConfig.ExecStart = "${pkgs.minio}/bin/minio server --address :9000 --console-address :9001 %S/minio";
    serviceConfig.StateDirectory = "minio";
    wantedBy = [ "multi-user.target" ];
  };

  # create nix bucket with public download permission
  systemd.services.create-nix-bucket = {
    after = [ "minio.service" ];
    unitConfig.ConditionPathExists = "!%S/minio/nix/nix-cache-info";
    environment.HOME = "%S/minio";
    serviceConfig.User = "minio";
    serviceConfig.EnvironmentFile = config.sops.templates.minio-root-credentials.path;
    preStart = "sleep 2"; # wait for minio server init
    script = ''
      ${pkgs.minio-client}/bin/mc alias set MY_MINIO http://127.0.0.1:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD
      ${pkgs.minio-client}/bin/mc mb --ignore-existing MY_MINIO/nix
      ${pkgs.minio-client}/bin/mc anonymous set download MY_MINIO/nix
      echo 'StoreDir: /nix/store' > /tmp/nix-cache-info
      ${pkgs.minio-client}/bin/mc cp /tmp/nix-cache-info MY_MINIO/nix
    '';
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.minio-api-proxy = {
    serviceConfig.ExecStart = "${pkgs.deno}/bin/deno run --allow-net ${./main.ts}";
    wantedBy = [ "multi-user.target" ];
  };

  services.traefik = {
    dynamicConfigOptions = {
      #############################################################################################
      # Hack
      http.routers.minio-api-proxy = {
        rule = "Host(`minio.${config.networking.domain}`) && Method(`GET`) && PathPrefix(`/nix/`) && HeadersRegexp(`User-Agent`, `aws-sdk-cpp`)";
        entryPoints = [ "web" "websecure" ];
        service = "minio-api-proxy";
      };
      http.services.minio-api-proxy.loadBalancer.servers = [{ url = "http://127.0.0.1:4507"; }];
      #############################################################################################
      # API
      http.routers.minio-api = {
        rule = "Host(`minio.${config.networking.domain}`)";
        entrypoints = [ "web" "websecure" ];
        service = "minio-api";
      };

      # Public nix bucket: Simplify: https://minio.mlyxshi.com/nix/HASH.narinfo  To: https://cache.mlyxshi.com/HASH.narinfo
      http.middlewares.add-nix.addprefix.prefix = "/nix";
      http.routers.minio-cache = {
        rule = "Host(`cache.${config.networking.domain}`)";
        entrypoints = [ "web" "websecure" ];
        middlewares = "add-nix";
        service = "minio-api";
      };

      http.services.minio-api.loadBalancer.servers = [{ url = "http://127.0.0.1:9000"; }];
      #######################################################################################
      # Dashboard
      http.routers.minio-dashboard = {
        rule = "Host(`minio-dashboard.${config.networking.domain}`)";
        entrypoints = [ "websecure" ];
        service = "minio-dashboard";
      };

      http.services.minio-dashboard.loadBalancer.servers = [{ url = "http://127.0.0.1:9001"; }];
    };
  };

}
