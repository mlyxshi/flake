{ config, pkgs, lib, ... }: {
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
    serviceConfig.ExecStart = "${pkgs.tftp-hpa}/bin/in.tftpd --user tftpd --verbose --listen --foreground --secure  %S/tftpd";
    postStart = ''
      [ -e "netboot.xyz.efi" ] || ${pkgs.wget}/bin/wget  https://boot.netboot.xyz/ipxe/netboot.xyz.efi
      [ -e "netboot.xyz-arm64.efi" ] || ${pkgs.wget}/bin/wget  https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi
      chmod 444 netboot.xyz.efi
      chmod 444 netboot.xyz-arm64.efi
    '';
    serviceConfig.User = "tftpd";
    serviceConfig.AmbientCapabilities = "CAP_NET_BIND_SERVICE";
    serviceConfig.WorkingDirectory = "%S/tftpd";
    serviceConfig.StateDirectory = "tftpd";
    wantedBy = [ "multi-user.target" ];
  };
}

# UEFI Shell
# FS0:
# ifconfig -s eth0 dhcp
# tftp 138.2.16.45 netboot.xyz.efi
# tftp 138.2.16.45 netboot.xyz-arm64.efi
# exit
