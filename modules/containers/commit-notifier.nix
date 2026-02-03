{
  config,
  pkgs,
  lib,
  ...
}:
{

  virtualisation.oci-containers.containers.commit-notifier = {
    image = "ghcr.io/mlyxshi/commit-notifier-arm64";
    volumes = [ "/var/lib/commit-notifier:/data" ];
    environmentFiles = [ /secret/commit-notifier ];
  };

}
