{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.containers.vaultwarden
  ];
}
