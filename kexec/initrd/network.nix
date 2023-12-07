{ config, pkgs, lib, ... }: {

  boot.initrd.systemd.network.enable = true;

  boot.initrd.systemd.network.networks.ethernet-default-dhcp = {
    matchConfig = { Name = [ "en*" "eth*" ]; };
    networkConfig = { DHCP = "yes"; };
  };

  boot.initrd.network.ssh.enable = true;

  boot.initrd.network.ssh.authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe" ];

  contents."/etc/ssh/ssh_host_ed25519_key".source = ./ed25519_key;
  contents."/etc/ssh/ssh_host_ed25519_key.pub".source = ./ed25519_key.pub; 
#   boot.initrd.systemd.services.setup-ssh-authorized-keys = {
#     after = [ "initrd-fs.target" ];
#     before = [ "sshd.service" ];
#     serviceConfig.Type = "oneshot";
#     script = ''
#       mkdir -p /etc/ssh/authorized_keys.d
#       param="$(get-kernel-param "ssh_authorized_key")"
#       if [ -n "$param" ]; then
#          umask 177
#          (echo -e "\n"; echo "$param" | base64 -d) >> /etc/ssh/authorized_keys.d/root
#          cat /etc/ssh/authorized_keys.d/root
#          echo "Using ssh authorized key from kernel parameter"
#       fi
#     '';
#     requiredBy = [ "sshd.service" ];
#   };

#   boot.initrd.systemd.services.generate-ssh-host-key = {
#     after = [ "initrd-fs.target" ];
#     before = [ "sshd.service" ];
#     serviceConfig.Type = "oneshot";
#     script = ''
#       mkdir -p /etc/ssh/
#       param="$(get-kernel-param "ssh_host_key")"
#       if [ -n "$param" ]; then
#          umask 177
#          echo "$param" | base64 -d > /etc/ssh/ssh_host_ed25519_key
#          ssh-keygen -y -f /etc/ssh/ssh_host_ed25519_key > /etc/ssh/ssh_host_ed25519_key.pub
#          echo "Using ssh host key from kernel parameter"
#       fi
#       if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
#          ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -t ed25519 -N ""
#          echo "Generated new ssh host key"
#       fi
#     '';
#     requiredBy = [ "sshd.service" ];
#   };
}
