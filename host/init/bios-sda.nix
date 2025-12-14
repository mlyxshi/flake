{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{

  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  networking.hostName = "bios-init-sda";
  nixpkgs.hostPlatform = "x86_64-linux";

  services.getty.autologinUser = "root";

  # Disable nixpkgs defined dhcp
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

  boot.loader.limine.enable = true;
  boot.loader.limine.biosSupport = true;
  boot.loader.limine.efiSupport = false;
  boot.loader.limine.biosDevice = "/dev/sda";
  boot.loader.limine.maxGenerations = 2;
  boot.loader.timeout = 0; # inmediate boot

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/sda2";
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
    package = pkgs.nixVersions.latest;
    channel.enable = false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "cgroups"
        "auto-allocate-uids"
      ];
      # substituters = [ "https://mlyxshi.cachix.org" ];
      # trusted-public-keys = [ "mlyxshi.cachix.org-1:BVd+/1A5uLMI8pTUdhdh6sdefTRdj+/PVgrUh9L2hWw=" ];
      log-lines = 25;
      # experimental
      use-cgroups = true;
      auto-allocate-uids = true;
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
    partitionTableType = "legacy+boot"; # limine bootloader
    baseName = "bios-init-sda-static";
    bootSize = "128M";
    additionalSpace = "128M";
  };
}
