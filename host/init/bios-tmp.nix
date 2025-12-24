{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{

  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

  networking.hostName = "bios-init-tmp";
  nixpkgs.hostPlatform = "x86_64-linux";

  services.getty.autologinUser = "root";

  # Disable nixpkgs defined dhcp
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  systemd.network.enable = true;
  systemd.network.wait-online.anyInterface = true;

  # systemd.network.networks.ethernet-default-dhcp = {
  #   matchConfig.Name = "en*";
  #   networkConfig.DHCP = "yes";
  # };

  # systemd.network.networks.ethernet-static = {
  #   matchConfig.Name = "en*";
  #   networkConfig = {
  #     Address = [
  #       "154.17.19.228/32"
  #     ];
  #     # Gateway = "161.248.63.1";
  #   };

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

  boot.loader.limine.enable = true;
  boot.loader.limine.biosSupport = true;
  boot.loader.limine.efiSupport = false;
  boot.loader.limine.biosDevice = "/dev/vda";
  boot.loader.limine.maxGenerations = 2;
  boot.loader.timeout = 2; # inmediate boot

  fileSystems."/boot" = {
    device = config.boot.loader.limine.biosDevice + "1";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = config.boot.loader.limine.biosDevice + "2";
    fsType = "ext4";
  };

  # boot.loader.grub.device = "/dev/vda";

  # fileSystems."/" = {
  #   device = "/dev/vda1";
  #   fsType = "ext4";
  # };

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
  system.disableInstallerTools = lib.mkForce false;
  environment.systemPackages = with pkgs; [
    git
    wget
    yq-go
  ];

  boot.initrd.kernelModules = [
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
    "virtio_balloon"
    "virtio_console"
    "9p"
    "9pnet_virtio"
  ]
  ++ [ "ext4" ]
  ++ [
    "vfat"
    "nls_cp437"
    "nls_iso8859-1"
  ]
  ++ [ "efivarfs" ]
  ++ [
    "erofs"
    "overlay"
  ]
  ++ [
    "iso9660"
    "scsi_mod"
  ];

  boot.initrd.systemd.storePaths = [
    "${pkgs.file}/share/misc/magic.mgc" # file dependency
  ];

  boot.initrd.systemd.extraBin = {
    # nix
    nix = "${pkgs.nix}/bin/nix";
    nix-store = "${pkgs.nix}/bin/nix-store";
    nix-env = "${pkgs.nix}/bin/nix-env";
    nixos-enter = "${pkgs.nixos-install-tools}/bin/nixos-enter";
    unshare = "${pkgs.util-linux}/bin/unshare"; # nixos-enter dependencies

    # net
    ip = "${pkgs.iproute2}/bin/ip";
    curl = "${pkgs.curl}/bin/curl";

    # fs
    "mkfs.fat" = "${pkgs.dosfstools}/bin/mkfs.fat";
    "mkfs.ext4" = "${pkgs.e2fsprogs}/sbin/mkfs.ext4";
    sgdisk = "${pkgs.gptfdisk}/bin/sgdisk"; # GPT
    parted = "${pkgs.parted}/bin/parted"; # MBR
    file = "${pkgs.file}/bin/file";
    lsblk = "${pkgs.util-linux}/bin/lsblk";
    blkid = "${pkgs.util-linux}/bin/blkid";

    # debug
    htop = "${pkgs.htop}/bin/htop";
    yazi = "${pkgs.yazi-unwrapped}/bin/yazi";
    hx = "${pkgs.helix}/bin/hx";
    yq = "${pkgs.yq-go}/bin/yq";
    # strace = "${pkgs.strace}/bin/strace";
  };

  boot.initrd.systemd.services.force-fail = {
    requiredBy = [ "initrd.target" ];
    before = [ "initrd.target" ];
    after = [ "cloud-init-network.service" ];
    serviceConfig.ExecStart = "/bin/false";
    unitConfig.OnFailure = [ "emergency.target" ];
  };

  boot.initrd.systemd.services.initrd-parse-etc.enable = false;
  system.nixos-init.enable = true;
  systemd.sysusers.enable = true;
  system.etc.overlay.enable = true;


  boot.initrd.systemd.network.enable = true;
  boot.initrd.systemd.services.cloud-init-network = {

    before = [ "systemd-networkd.service" ];
    wantedBy = [ "initrd.target" ];

    # unitConfig.OnFailure = "myservice-failed.service";

    requires = [ "dev-disk-by\\x2dlabel-cidata.device" ];
    after = [ "dev-disk-by\\x2dlabel-cidata.device" ];

    script = ''
      mkdir -p /cloud-init
      mount /dev/disk/by-label/cidata /cloud-init

      NETWORKD_CONF="/etc/systemd/network/ethernet.network"
      CLOUD_INIT_CONF="/cloud-init/network-config"

      VERSION=$(yq .version $CLOUD_INIT_CONF)

      if [ "$VERSION" = "1" ]; then
        IP=$(yq .config[0].subnets[0].address $CLOUD_INIT_CONF)
        NETMASK=$(yq .config[0].subnets[0].netmask $CLOUD_INIT_CONF)
        GATEWAY=$(yq .config[0].subnets[0].gateway $CLOUD_INIT_CONF)

        if [ "$NETMASK" = "255.255.255.255" ]; then
          CIDR=32
        elif [ "$NETMASK" = "255.255.255.0" ]; then
          CIDR=24
        else
          echo "Unsupported netmask: $NETMASK" >&2
          exit 1
        fi

        {
          echo "[Match]"
          echo "Name=en*"
          echo
          echo "[Network]"
          echo "Address=$IP/$CIDR"
          echo
          echo "[Route]"
          echo "Gateway=$GATEWAY"
          if [ "$CIDR" -eq 32 ]; then
            echo "GatewayOnLink=yes"
          fi
        } > $NETWORKD_CONF

      elif [ "$VERSION" = "2" ]; then
        IP=$(yq .ethernets.eth0.addresses[0] $CLOUD_INIT_CONF)
        GATEWAY=$(yq .ethernets.eth0.gateway4 $CLOUD_INIT_CONF)
        {
          echo "[Match]"
          echo "Name=en*"
          echo
          echo "[Network]"
          echo "Address=$IP"
          echo
          echo "[Route]"
          echo "Gateway=$GATEWAY"
        } > $NETWORKD_CONF
        case "$IP" in
          */32)
            echo "CIDR is /32"
            echo "GatewayOnLink=yes" >> $NETWORKD_CONF
            ;;
          *)
            echo "CIDR is not /32"
            ;;
        esac

      fi
    '';
  };

  system.build.raw = import "${pkgs.path}/nixos/lib/make-disk-image.nix" {
    inherit config lib pkgs;
    format = "raw";
    copyChannel = false;
    partitionTableType = "legacy+boot"; # limine bootloader
    # partitionTableType = "legacy"; # grub bootloader
    bootSize = "300M";
    # additionalSpace = "128M";
    # diskSize = 10240; # 10G
    diskSize = 20480; # 20G
    baseName = config.networking.hostName;
  };
}
