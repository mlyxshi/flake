{
  config,
  pkgs,
  lib,
  ...
}:
{
  virtualisation.oci-containers.containers.commit-notifier = {
    image = "ghcr.io/linyinfeng/commit-notifier";
    volumes = [ "/var/lib/commit-notifier:/data" ];
    environmentFiles = [ /secret/commit-notifier ];
    extraOptions = [
      "--label"
      "io.containers.autoupdate=registry"
    ];
  };
}
