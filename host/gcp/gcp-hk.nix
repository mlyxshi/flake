{ self, pkgs, lib, config, ... }: {
  # imports = [
  #   self.nixosModules.containers.podman
  # ];

  # virtualisation.oci-containers.containers.whmcs = {
  #   image = "docker.io/vpslog/vps-stock-monitor";
  #   volumes = [ "/var/lib/whmcs:/app/data" ];
  #   ports = [ "5000:5000" ];
  #   extraOptions = lib.concatMap (x: [ "--label" x ]) [
  #     "io.containers.autoupdate=registry"
  #   ];
  # };



  # networking.nftables.enable = true;
  # networking.nftables.ruleset = ''
  # '';  

}
