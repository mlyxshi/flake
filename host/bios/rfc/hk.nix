{ pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  fileSystems."/" = { device = "/dev/vda1"; fsType = "xfs"; };

  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_slow_start_after_idle" = 0; #https://www.kawabangga.com/posts/5217
  };

  boot.kernelParams = [ "net.ifnames=0" ];

  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  systemd.network.enable = true;
  systemd.network.wait-online.anyInterface = true;
  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = "104.251.236.158/24";
      Gateway = "104.251.236.1";
      DNS = "1.1.1.1";
    };
  };

  networking.firewall.enable = false;

  systemd.services.ss = {
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.shadowsocks-rust}/bin/ssserver -c /secret/shadowsocks";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
