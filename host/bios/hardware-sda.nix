{ modulesPath, pkgs, lib, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "cake";
    "net.core.netdev_max_backlog" = 80000;
    "net.core.rmem_max" = 796144826;
    "net.core.wmem_max" = 682409851;
    "net.core.rmem_default" = 262144;
    "net.core.wmem_default" = 262144;
    "net.core.somaxconn" = 40960;
    "net.core.optmem_max" = 262144;

    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_timestamps" = 1;
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_fin_timeout" = 10;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_max_tw_buckets" = 32768;
    "net.ipv4.tcp_sack" = 1;
    "net.ipv4.tcp_fack" = 1;

    "net.ipv4.tcp_rmem" = "32768 262144 796144826";
    "net.ipv4.tcp_wmem" = "32768 262144 682409851";
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_notsent_lowat" = 524288;
    "net.ipv4.tcp_window_scaling" = 1;
    "net.ipv4.tcp_adv_win_scale" = 7;
    "net.ipv4.tcp_moderate_rcvbuf" = 1;
    "net.ipv4.tcp_no_metrics_save" = 1;
    "net.ipv4.tcp_init_cwnd" = 32;

    "net.ipv4.tcp_max_syn_backlog" = 327680;
    "net.ipv4.tcp_max_orphans" = 32768;
    "net.ipv4.tcp_synack_retries" = 2;
    "net.ipv4.tcp_syn_retries" = 2;
    "net.ipv4.tcp_abort_on_overflow" = 0;
    "net.ipv4.tcp_stdurg" = 0;
    "net.ipv4.tcp_rfc1337" = 0;
    "net.ipv4.tcp_syncookies" = 1;
  };

}
