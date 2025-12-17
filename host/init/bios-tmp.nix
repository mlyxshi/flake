{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{

  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  networking.hostName = "bios-init-tmp";
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

  # systemd.network.networks.ethernet-static = {
  #   matchConfig.Name = "en*";
  #   networkConfig.Address = "154.17.19.228/32";
  #   routes = [
  #     {
  #       Gateway = "193.41.250.250";
  #       GatewayOnLink = true; # Special config since gateway isn't in subnet
  #     }
  #   ];
  # };

  networking.firewall.enable = false;

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  # boot.loader.limine.enable = true;
  # boot.loader.limine.biosSupport = true;
  # boot.loader.limine.efiSupport = false;
  # boot.loader.limine.biosDevice = "/dev/vda";
  # boot.loader.limine.maxGenerations = 2;
  # boot.loader.timeout = 3; # inmediate boot

  # fileSystems."/boot" = {
  #   device = "/dev/vda1";
  #   fsType = "vfat";
  # };

  # fileSystems."/" = {
  #   device = "/dev/vda2";
  #   fsType = "ext4";
  # };

  boot.loader.grub.device = "/dev/sda";

  fileSystems."/" = {
    device = "/dev/sda1";
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

  environment.systemPackages = with pkgs; [
    git
    wget
  ];

  system.build.raw = import "${pkgs.path}/nixos/lib/make-disk-image.nix" {
    inherit config lib pkgs;
    format = "raw";
    copyChannel = false;
    # partitionTableType = "legacy+boot"; # limine bootloader
    partitionTableType = "legacy"; # grub bootloader
    bootSize = "300M";
    # additionalSpace = "128M";
    # diskSize = 10240; # 10G
    # diskSize = 20480; # 20G
    baseName = config.networking.hostName;
  };
}
