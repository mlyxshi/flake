  # Do not use cloudflared, <--bandwidth limit

  # sops.secrets.cloudflared-tunnel-us-env = { };
  # systemd.services.cloudflared = {
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network-online.target" "systemd-resolved.service" ];
  #   serviceConfig = {
  #     ExecStart = ''
  #       ${pkgs.bash}/bin/bash -c "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token=$TOKEN"
  #     '';
  #     # Restart = "always";
  #     EnvironmentFile = config.sops.secrets.cloudflared-tunnel-us-env.path;
  #   };
  # };


  # virtualisation.oci-containers.containers = {
  #   "librespeed" = {
  #     image = "linuxserver/librespeed";
  #     extraOptions = [
  #       "--label"
  #       "traefik.enable=true"
  #       "--label"
  #       "traefik.http.routers.librespeed.rule=Host(`librespeed.${config.networking.domain}`)"
  #     ];
  #   };
  # };