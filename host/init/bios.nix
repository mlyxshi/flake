{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{

  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

  networking.hostName = "nixos-example";
  nixpkgs.hostPlatform = "x86_64-linux";

  services.getty.autologinUser = "root";

  # Disable nixpkgs defined dhcp
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  systemd.network.enable = true;
  systemd.network.wait-online.anyInterface = true;

  systemd.network.networks.ethernet-default-dhcp = {
    matchConfig.Name = "en*";
    networkConfig.DHCP = "yes";
  };

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  boot.loader.limine.enable = true;
  boot.loader.limine.biosSupport = true;
  boot.loader.limine.efiSupport = false;
  boot.loader.limine.biosDevice = "/dev/vda";
  boot.loader.limine.maxGenerations = 2;
  boot.loader.timeout = 1;

  fileSystems."/boot" = {
    device = config.boot.loader.limine.biosDevice + "2";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = config.boot.loader.limine.biosDevice + "3";
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

  nix = {
    channel.enable = false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

}
