{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.containers.podman
  ];

  virtualisation.oci-containers.containers.netboot-tftp = {
    image = "ghcr.io/linuxserver/netbootxyz:tftp";
    ports = [
      "69:69/udp"
    ];
    environment = {
      PUID = "1000";
      PGID = "1000";
    };
  };

}


# UEFI Shell for aarch64
# FS0:
# ifconfig -s eth0 dhcp
# tftp 138.2.16.45 netboot.xyz.efi
# exit
