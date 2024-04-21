{ self, pkgs, lib, config, ... }: {
  imports = [
    # self.nixosModules.services.hysteria


    # self.nixosModules.services.transmission

    # self.nixosModules.containers.podman
    # self.nixosModules.containers.netboot-tftp

    # self.nixosModules.containers.navidrome
    # self.nixosModules.containers.change-detection
    # self.nixosModules.containers.baidunetdisk
  ];

  networking.nftables.enable = lib.mkForce false;
}
