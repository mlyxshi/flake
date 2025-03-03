{ config, pkgs, lib, ... }: {
  services.atftpd.enable = true;
  services.atftpd.root = "/var/lib/netboot";
}

# cd /var/lib/netboot
# wget  https://boot.netboot.xyz/ipxe/netboot.xyz.efi
# wget  https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi
# UEFI Shell
# FS0:
# ifconfig -s eth0 dhcp
# tftp 138.3.223.82 netboot.xyz.efi
# tftp 138.3.223.82 netboot.xyz-arm64.efi
# exit