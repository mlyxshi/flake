{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.hysteria
    self.nixosModules.containers.netboot-tftp
    self.nixosModules.containers.baidunetdisk
  ];
}
