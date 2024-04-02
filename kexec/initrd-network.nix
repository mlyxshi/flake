{ config, pkgs, lib, ... }: {
  # systemd-networkd
  boot.initrd.systemd.network.enable = true;

  boot.initrd.systemd.network.networks.ethernet-default-dhcp = {
    matchConfig = { Name = [ "en*" "eth*" ]; };
    networkConfig = { DHCP = "yes"; };
  };

  # systemd-resolved
  boot.initrd.systemd.users.systemd-resolve = { };
  boot.initrd.systemd.groups.systemd-resolve = { };
  boot.initrd.systemd.additionalUpstreamUnits = [ "systemd-resolved.service" ];
  boot.initrd.systemd.storePaths =
    [ "${config.boot.initrd.systemd.package}/lib/systemd/systemd-resolved" ];
  boot.initrd.systemd.services.systemd-resolved.wantedBy = [ "initrd.target" ];

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/resolved.nix
  # In initrd, create a symlink to the stub-resolv.conf
  boot.initrd.systemd.services.symlink-etc-resolv-conf = {
    after = [ "systemd-resolved.service" ];
    serviceConfig.Type = "oneshot";
    script = "ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf";
    requiredBy = [ "systemd-resolved.service" ];
  };

  # sshd
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.authorizedKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe";
  boot.initrd.systemd.services.generate-ssh-host-key = {
    after = [ "initrd-fs.target" ];
    before = [ "sshd.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /etc/ssh/
      ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -t ed25519 -N ""
      echo "Generated ssh host key"
    '';
    requiredBy = [ "sshd.service" ];
  };
}
