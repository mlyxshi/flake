{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.containers.auto-bangumi
  ];

  services.atftpd.enable = true;
  services.atftpd.root = "/var/lib/tftp";
  # Since atftpd run as the nobody user, the permission of the directory must be set properly to allow file reading and writing.
}
