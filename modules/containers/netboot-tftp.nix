{ config, pkgs, lib, self, ... }: {

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
# tftp 138.3.223.82 arm.efi
# exit