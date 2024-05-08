{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.containers.auto-bangumi
  ];

  services.atftpd.enable = true;
  services.atftpd.root = "/var/lib/tftp";
  systemd.services.atftpd.serviceConfig.User = "root";
}
