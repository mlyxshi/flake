{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.containers.auto-bangumi
  ];

  users = {
    users.tftpd = {
      group = "tftpd";
      isSystemUser = true;
    };
    groups.tftpd = { };
  };

  # https://manpages.debian.org/testing/tftpd-hpa/tftpd.8.en.html
  systemd.services.tftpd = {
    after = [ "network-online.target" ];
    serviceConfig.ExecStart = "${pkgs.tftp-hpa}/bin/in.tftpd --user tftpd --verbose --verbose --listen --foreground --secure  %S/tftpd";
    postStart = ''
      [ -e "arm.efi" ] || ${pkgs.curl}/bin/curl -Lo arm.efi  https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi
      chmod 444 arm.efi
    '';
    serviceConfig.User = "tftpd";
    serviceConfig.AmbientCapabilities = "CAP_NET_BIND_SERVICE";
    serviceConfig.WorkingDirectory = "%S/tftpd";
    serviceConfig.StateDirectory = "tftpd";
    wantedBy = [ "multi-user.target" ];
  };
}
