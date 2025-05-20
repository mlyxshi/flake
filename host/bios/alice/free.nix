{ modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.device = "/dev/vda";
  
  boot.initrd.kernelModules = [ "nvme" ];

  fileSystems."/" = { device = "/dev/vda3"; fsType = "xfs"; };

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
      Address = "91.103.121.190/27";
      Gateway = "91.103.121.161";
      DNS = "181.215.6.75";
    };
  };

  networking.firewall.enable = false;
}
