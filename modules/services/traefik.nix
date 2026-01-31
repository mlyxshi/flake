{
  lib,
  config,
  ...
}:
{
  services.traefik = {
    enable = true;
    group = if config.virtualisation.podman.enable then "podman" else "traefik"; # podman backend

    dynamicConfigOptions = {

      http.middlewares = {
        web-redirect.redirectScheme.scheme = "https";
        #  mkpasswd
        auth.basicauth = {
          users = "{{ env `TRAEFIK_AUTH` }}";
          removeheader = true;
        };
      };

      http.routers.api = {
        rule = "Host(`${config.networking.fqdn}`)";
        entrypoints = "web";
        service = "api@internal";
        middlewares = "auth";
      };
    };

    staticConfigOptions = {
      api = { };

      entryPoints = {
        web = {
          address = ":80";
        };

        websecure = {
          address = ":443";
          http.tls.certResolver = "letsencrypt";
        };
      };

      certificatesResolvers.letsencrypt.acme = {
        dnsChallenge.provider = "cloudflare";
        email = "blackhole@${config.networking.domain}";
        storage = "${config.services.traefik.dataDir}/acme.json"; # "/var/lib/traefik/acme.json"
      };
    }
    // lib.optionalAttrs config.virtualisation.podman.enable {
      providers.docker = {
        endpoint = "unix:///run/podman/podman.sock";
        exposedByDefault = false;
      };
    };
  };
}
