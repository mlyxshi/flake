{ config, pkgs, lib, self, ... }: {

  imports = [ self.nixosModules.containers.podman ];

  virtualisation.oci-containers.containers.netboot-tftp = {
    image = "docker.io/langren1353/netboot-shell-tftp";
    ports = [ "69:69/udp" ];
    environment = {
      "PUID" = "1111";
      "PGID" = "1112";
    };
  };
}

# UEFI Shell for aarch64
# FS0:
# ifconfig -s eth0 dhcp
# tftp 138.2.16.45 arm.efi
# exit
