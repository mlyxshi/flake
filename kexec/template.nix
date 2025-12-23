{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  imports = [ ./default.nix ];

  # Preset dhcp
  boot.initrd.systemd.network.networks.ethernet = {
    matchConfig.Name = "en*";
    networkConfig.DHCP = "yes";
  };

  # Very limited cloud-init network setup implementation. Only test on cloud provider I use
  boot.initrd.systemd.services.cloud-init-network = {

    before = [ "systemd-networkd.service" ];
    wantedBy = [ "systemd-networkd.service" ];
    serviceConfig.ConditionPathExists = "/dev/disk/by-label/cidata";

    script = ''
      mkdir -p /cloud-init
      mount /dev/disk/by-label/cidata /cloud-init

      VERSION=$(yq .version $CLOUD_INIT_CONF)
      NETWORKD_CONF="/etc/systemd/network/ethernet.network"
      CLOUD_INIT_CONF="/cloud-init/network-config"

      if [ "$VERSION" = "1" ]; then
        IP=$(yq .config[0].subnets[0].address $CLOUD_INIT_CONF)
        NETMASK=$(yq .config[0].subnets[0].netmask $CLOUD_INIT_CONF)
        GATEWAY=$(yq .config[0].routes[0].gateway $CLOUD_INIT_CONF)
        
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
          echo "Address=${IP}/${CIDR}"
          echo
          echo "[Route]"
          echo "Gateway=${GATEWAY}"
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
          echo "Address=${IP}"
          echo
          echo "[Route]"
          echo "Gateway=${GATEWAY}"
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

}
