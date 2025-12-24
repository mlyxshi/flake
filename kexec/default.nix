{
  config,
  pkgs,
  lib,
  ...
}:
{

  system.nixos-init.enable = true;

  networking.hostName = "systemd-initrd";

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.network.enable = true;

  boot.initrd.network.ssh.enable = true;
  boot.initrd.systemd.services.sshd.preStart =
    lib.mkForce "/bin/chmod 0600 /etc/ssh/ssh_host_ed25519_key";

  # remove unused lvm/bcache from initrd
  boot.initrd.services.lvm.enable = false;
  boot.bcache.enable = false;

  # https://github.com/NixOS/nixpkgs/blob/master/lib/systems/platforms.nix
  # aarch64-multiplatform { autoModules = true;  preferBuiltin = true;}
  # x86-64 { autoModules = true; }
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/kernel/modules-closure.nix

  # qemu + ext4 + vfat + efivarfs + overlay + iso9660
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
    "iso9660" # cloud-init cidata disk
    "scsi_mod"
  ]; 
  # boot.initrd.includeDefaultModules also adds some necessary modules

  boot.initrd.systemd.contents = {
    "/etc/ssl/certs/ca-certificates.crt".source = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    "/etc/ssh/authorized_keys.d/root".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe";
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/keys
    "/etc/ssh/ssh_host_ed25519_key.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBWcxb/Blaqt1auOtE+F8QUWrUotiC5qBJ+UuEWdVCb";
    "/etc/ssh/ssh_host_ed25519_key".text = ''
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
      QyNTUxOQAAACCQVnMW/wZWqrdWrjrRPhfEFFq1KLYguagSflLhFnVQmwAAAJASuMMnErjD
      JwAAAAtzc2gtZWQyNTUxOQAAACCQVnMW/wZWqrdWrjrRPhfEFFq1KLYguagSflLhFnVQmw
      AAAEDIN2VWFyggtoSPXcAFy8dtG1uAig8sCuyE21eMDt2GgJBWcxb/Blaqt1auOtE+F8QU
      WrUotiC5qBJ+UuEWdVCbAAAACnJvb3RAbml4b3MBAgM=
      -----END OPENSSH PRIVATE KEY-----
    '';

    "/etc/nix/nix.conf".text = ''
      extra-experimental-features = nix-command flakes
      substituters = https://cache.nixos.org
      trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
    '';

    "/etc/yazi/yazi.toml".text = ''
      [manager]
      show_hidden = true
      linemode = "size"
    '';
    # https://github.com/NixOS/nixpkgs/blob/3c6867e2f20b8584b03deb6d2b13d0ee0b4ad650/nixos/modules/config/users-groups.nix#L814
    "/etc/profile".text = ''
      PS1="\e[0;32m\]\u@\h \w >\e[0m\] "
      alias r=yazi
      export HOME=/root
      export EDITOR=hx
      export YAZI_CONFIG_HOME=/etc/yazi
      cd /
    '';

    "/root/.terminfo".source = ./.terminfo; # macos default terminal is xterm-256color
  };

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

  boot.initrd.systemd.emergencyAccess = true;

  # force fail for debugging without openssh access
  # boot.initrd.systemd.services.force-fail = {
  #   wantedBy = [ "initrd.target" ];
  #   before = [ "initrd.target" ];
  #   after = [ "initrd-root-fs.target" ];
  #   serviceConfig.ExecStart = "/bin/false";
  #   unitConfig.OnFailure = [ "emergency.target" ];
  # };

  boot.initrd.systemd.services.initrd-parse-etc.enable = false;
  # https://www.freedesktop.org/software/systemd/man/latest/bootup.html#Bootup%20in%20the%20initrd
  # https://github.com/systemd/systemd/blob/main/units/initrd-parse-etc.service.in
  # https://github.com/systemd/systemd/blob/main/units/initrd-cleanup.service
  # Disable: initrd-parse-etc.service -> initrd-cleanup.service -> initrd-switch-root.target
  # so systemd will reach initrd.target. Unit will not be cleanup and act like a mini live nixos system.

  # Preset DHCP
  # boot.initrd.systemd.network.networks.ethernet = {
  #   matchConfig.Name = "en*";
  #   networkConfig.DHCP = "yes";
  # };

  systemd.network.networks.ethernet = {
    matchConfig.Name = "en*";
    networkConfig = {
      Address = [
        "161.248.63.190/24"
      ];
    };

    routes = [
      {
        Gateway = "161.248.63.1";
      }
    ];
  };

  # Very limited cloud-init network setup implementation. Only test on cloud provider I use

  # If /dev/disk/by-label/cidata appear in 5s, read /cloud-init/network-config and setup networkd
  # If /dev/disk/by-label/cidata does not appear, cloud-init-network will fail, networkd will use preset DHCP
  boot.initrd.systemd.services.cloud-init-network = {

    before = [ "systemd-networkd.service" ];

    wantedBy = [ "initrd.target" ];
    serviceConfig.Type = "oneshot";

    serviceConfig.ExecStartPre = "/bin/sleep 5"; # Wait cidata appear

    script = ''
      if [ ! -e /dev/disk/by-label/cidata ]; then
        echo "cidata disk not found, skipping cloud-init network config"
        exit 1
      fi

      mkdir -p /cloud-init
      mount /dev/disk/by-label/cidata /cloud-init
      mkdir -p /etc/systemd/network/
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
        GATEWAY4=$(yq .ethernets.eth0.gateway4 $CLOUD_INIT_CONF)
        
        if [ "$GATEWAY4" = "null" ]; then
          echo "IPV6 Only"
          GATEWAY6=$(yq '.ethernets.eth0.gateway6' $CLOUD_INIT_CONF)
          {
            echo "[Match]"
            echo "Name=en*"
            echo
            echo "[Network]"
            echo "Address=''${IP%%/*}/128"
            echo
            echo "[Route]"
            echo "Gateway=$GATEWAY6"
            echo "GatewayOnLink=yes"
          } > $NETWORKD_CONF
        else
          echo "Use IPV4"
          {
            echo "[Match]"
            echo "Name=en*"
            echo
            echo "[Network]"
            echo "Address=$IP"
            echo
            echo "[Route]"
            echo "Gateway=$GATEWAY4"
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
      fi
    '';
  };

}
