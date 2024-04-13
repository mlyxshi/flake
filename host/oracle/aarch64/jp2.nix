{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.hysteria
    # self.nixosModules.containers.podman
    # self.nixosModules.containers.netboot-tftp
  ];
}
