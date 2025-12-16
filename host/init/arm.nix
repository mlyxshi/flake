{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{

  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/image/repart.nix"
  ];

  networking.hostName = "arm-init-sda-grow";
  nixpkgs.hostPlatform = "aarch64-linux";

  services.getty.autologinUser = "root";

  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  systemd.network.enable = true;
  systemd.network.wait-online.anyInterface = true;
  systemd.network.networks.ethernet-default-dhcp = {
    matchConfig.Name = "en*";
    networkConfig.DHCP = "yes";
  };
  networking.firewall.enable = false;

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  boot.initrd.systemd.root = "gpt-auto";
  boot.initrd.supportedFilesystems = [ "ext4" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.timeout = 1;
  boot.loader.efi.canTouchEfiVariables = true;

  # resize root partition and filesystem after switch-root
  systemd.repart.enable = true;
  systemd.repart.partitions = {
    root = {
      Type = "root";
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

  image.repart = {
    name = config.networking.hostName;
    partitions = {
      "esp" = {
        contents =
          let
            efiArch = config.nixpkgs.hostPlatform.efiArch;
          in
          {
            "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
              "${config.systemd.package}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

            "/EFI/systemd/systemd-boot${efiArch}.efi".source =
              "${config.systemd.package}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

            "/EFI/nixos/${config.system.boot.loader.kernelFile}".source =
              "${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile}";

            "/EFI/nixos/${config.system.boot.loader.initrdFile}".source =
              "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";

            "/loader/entries/nixos-generation-1.conf".source = pkgs.writeText "nixos-generation-1.conf" ''
              title NixOS Init
              linux /EFI/nixos/${config.system.boot.loader.kernelFile}
              initrd /EFI/nixos/${config.system.boot.loader.initrdFile}
              options init=${config.system.build.toplevel}/init ${builtins.toString config.boot.kernelParams}
            '';

            "/EFI/netbootxyz.efi".source = "${pkgs.netbootxyz-efi}"; # emergency rescue on oracle arm
          };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
          SizeMinBytes = "300M";
        };
      };
      "root" = {
        storePaths = [ config.system.build.toplevel ];
        repartConfig = {
          Type = "root";
          Format = "ext4";
          Minimize = "guess";
        };
      };
    };
  };

}
