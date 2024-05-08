{ self, pkgs, lib, config, modulesPath, ... }: {
  imports = [
    # self.nixosModules.services.hysteria


    self.nixosModules.services.transmission

    # self.nixosModules.containers.podman
    # self.nixosModules.containers.netboot-tftp

    # self.nixosModules.containers.navidrome
    # self.nixosModules.containers.change-detection
    # self.nixosModules.containers.baidunetdisk

    "${modulesPath}/profiles/perlless.nix"
  ];

  # system.switch.enable = false;
}
