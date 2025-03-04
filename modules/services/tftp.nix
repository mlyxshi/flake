{ config, pkgs, lib, ... }: {
  services.atftpd.enable = true;
  services.atftpd.root = "/var/lib/netboot";
}

# cd /var/lib/netboot
# wget  https://boot.netboot.xyz/ipxe/netboot.xyz.efi
# wget  https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi