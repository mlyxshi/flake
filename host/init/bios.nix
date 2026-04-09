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
  # nixpkgs.hostPlatform = "aarch64-linux";

  services.getty.autologinUser = "root";

  # Disable nixpkgs defined dhcp
  networking.useDHCP = false;

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

  # Very limited cloud-init network setup implementation. Only test on cloud provider I use (dmit.io)
  services.udev.extraRules = ''
    SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="cidata", TAG+="systemd", ENV{SYSTEMD_WANTS}="cloud-init-network.service"
  '';

  systemd.services.cloud-init-network = {
    serviceConfig.Type = "oneshot";
    path = [
      pkgs.yq-go
      pkgs.util-linux
    ];

    script = ''
      mkdir -p /cloud-init
      mount /dev/disk/by-label/cidata /cloud-init
      mkdir -p /run/systemd/network/
      NETWORKD_CONF="/run/systemd/network/ethernet.network"
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
          echo "Unsupported netmask: $NETMASK"
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

      systemctl reload-or-restart systemd-networkd.service
    '';
  };

}
