{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{

  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  networking.hostName = "utm";
  nixpkgs.hostPlatform = "aarch64-linux";

  services.getty.autologinUser = "root";

  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  systemd.network.enable = true;
  systemd.network.wait-online.anyInterface = true;
  systemd.network.networks.ethernet-default-dhcp = {
    matchConfig = {
      Name = [
        "en*"
        "eth*"
      ];
    };
    networkConfig = {
      DHCP = "yes";
    };
  };
  networking.firewall.enable = false;

  boot.kernelParams = [ "net.ifnames=0" ];

  boot.initrd.systemd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.timeout = 1;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.netbootxyz.enable = true; # emergency rescue on oracle arm

  fileSystems."/boot" = {
    device = "/dev/vda1";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/vda2";
    fsType = "ext4";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe"
  ];

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings.PasswordAuthentication = false;
  };

}