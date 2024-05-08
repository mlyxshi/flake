{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.containers.auto-bangumi
  ];

  services.tftpd.enable = true;
  services.tftpd.path = "/var/lib/tftp";
}
