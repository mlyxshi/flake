{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.containers.auto-bangumi
  ];

  services.atftpd.enable = true;
  systemd.services.atftpd.serviceConfig.User = "root";
}
