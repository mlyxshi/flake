{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.containers.podman
  ];

  virtualisation.oci-containers.containers.netboot-tftp = {
    image = "ghcr.io/netbootxyz/netbootxyz";
    ports = [ "69:69/udp" ];
  };

}

# UEFI Shell
# FS0:
# ifconfig -s eth0 dhcp
# tftp 138.2.16.45 amd.efi
# tftp 138.2.16.45 arm.efi
# exit
