{ pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  fileSystems."/" = { device = "/dev/vda1"; fsType = "xfs"; };

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

  # Port 22 for FCC
  services.openssh.ports = [ 2222 ];
}
