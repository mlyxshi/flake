{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.containers.auto-bangumi
  ];

  virtualisation.oci-containers.containers.netboot-tftp = {
    image = "docker.io/langren1353/netboot-shell-tftp";
    ports = [ "69:69/udp" ];
    environment = {
      "PUID" = "1111";
      "PGID" = "1112";
    };
  };

  # services.atftpd.enable = true;
  # services.atftpd.root = "/var/lib/tftp";
  # Since atftpd run as the nobody user, the permission of the directory must be set properly to allow file reading and writing.
}
