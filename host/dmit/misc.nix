{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  services.getty.autologinUser = "root";

  boot.loader.grub.device = "/dev/vda"; # dmit original grub -> nixos systemd-initrd

  # https://gist.github.com/dramforever/bf339cb721d25892034e052765f931c6
  fileSystems."/old-root" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
    options = [ "X-mount.subdir=new-root" ];
  };
  fileSystems."/nix" = {
    device = "/dev/vda1";
    fsType = "ext4";
    options = [ "X-mount.subdir=nix" ];
  };

  systemd.network.networks.ethernet-static = {
    matchConfig.Name = "en*";
    networkConfig.Address="154.17.19.228/32";
    routes = [
      {
        Gateway = "193.41.250.250";
        GatewayOnLink = true; # Special config since gateway isn't in subnet
      }
    ];
  };

  # networking.nftables.enable = true;
  # networking.nftables.ruleset = ''
  #   table inet FIREWALL {
  #     chain INPUT {
  #       type filter hook input priority 0; policy drop;
  #       iifname lo accept
  #       ip protocol icmp accept
  #       ip6 nexthdr icmpv6 accept
  #       ct state {established, related} accept
  #       tcp dport { 22, 8888 } accept
  #       udp dport { 8888 } accept
  #     }
  #   }
  # '';

  # systemd.services.komari-agent.environment.AGENT_MONTH_ROTATE = "24";
}
