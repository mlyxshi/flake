{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.containers.podman
  ];

  virtualisation.oci-containers.containers.netboot-tftp = {
    image = "lscr.io/linuxserver/netbootxyz:tftp";
    ports = [
      "69:69/udp"
      "3000:3000"
    ];
    environment = {
      PUID = "1000";
      PGID = "1000";
    };
  };

}

# UEFI Shell
# FS0:
# ifconfig -s eth0 dhcp
# tftp 138.2.16.45 netboot.xyz.efi
# tftp 138.2.16.45 netboot.xyz-arm64.efi
# exit
