{ config, pkgs, lib, ... }: {
  # systemd-networkd
  boot.initrd.systemd.network.enable = true;

  boot.initrd.systemd.network.networks.ethernet-default-dhcp = {
    matchConfig = { Name = [ "en*" "eth*" ]; };
    networkConfig = { DHCP = "yes"; };
  };

  # sshd
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe" ];

  boot.initrd.systemd.services.generate-ssh-host-key = {
    before = [ "sshd.service" ];
    unitConfig.ConditionPathExists = "!/etc/ssh/ssh_host_ed25519_key";
    serviceConfig.Type = "oneshot";
    script = ''ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -t ed25519 -N ""'';
    requiredBy = [ "sshd.service" ];
  };
}
