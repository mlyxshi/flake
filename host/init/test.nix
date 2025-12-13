{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/image/repart.nix
  ];

  networking.hostName = "arm-init";
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

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-partlabel/nixos";
      fsType = "ext4";
    };
  };

  boot.initrd.systemd.repart.enable = true;
  boot.initrd.systemd.repart.device = "/dev/vda";
  systemd.repart.partitions = {
    root = {
      Type = "root"; # resize root partition and filesystem
      GrowFileSystem = "yes";
    };
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
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
  };

  environment.systemPackages = with pkgs; [
    git
    wget
  ];
}
