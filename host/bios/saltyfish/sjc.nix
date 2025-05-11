{ config, pkgs, lib, modulesPath, ... }: {

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  boot.loader.grub.device = "/dev/vda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/vda2"; fsType = "ext4"; };


  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_slow_start_after_idle" = 0; #https://www.kawabangga.com/posts/5217

    # Optimize long-distance TCP connections.  https://tcp-cal.mereith.com
    "net.ipv4.tcp_rmem" = lib.mkForce "4096 87380 17500000";
    "net.ipv4.tcp_wmem" = lib.mkForce "4096 16384 17500000";
  };

  boot.kernelParams = [ "net.ifnames=0" ];


  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  systemd.network.enable = true;
  systemd.services.systemd-networkd.environment.SYSTEMD_LOG_LEVEL = "debug";
  systemd.network.wait-online.anyInterface = true;
  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = "185.218.6.86/24";
      Gateway = "185.218.6.1";
      DNS = "1.1.1.1";
    };
  };

  networking.firewall.enable = false;
}
