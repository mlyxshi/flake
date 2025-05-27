{ pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  fileSystems."/" = { device = "/dev/vda3"; fsType = "xfs"; };

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
}
