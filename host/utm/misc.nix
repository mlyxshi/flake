{ config, pkgs, lib, self, ... }:
let
  install-aarch64 = pkgs.writeShellScriptBin "install-aarch64" ''
    HOST=$1
    IP=$2

    cd /flake
    git pull 

    outPath=$(nix build --no-link --print-out-paths .#nixosConfigurations.$HOST.config.system.build.toplevel)
    
    until ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$IP -- exit 0; do sleep 5; done
    ssh -o StrictHostKeyChecking=no root@$IP make-partitions
    ssh -o StrictHostKeyChecking=no root@$IP mount-partitions

    NIX_SSHOPTS='-o StrictHostKeyChecking=no' nix copy --substitute-on-destination --to ssh://root@$IP?remote-store=local?root=/mnt $outPath       

    ssh -o StrictHostKeyChecking=no root@$IP nix-env --store /mnt -p /mnt/nix/var/nix/profiles/system --set $outPath
    ssh -o StrictHostKeyChecking=no root@$IP mkdir /mnt/{etc,tmp}
    ssh -o StrictHostKeyChecking=no root@$IP touch /mnt/etc/NIXOS
    ssh -o StrictHostKeyChecking=no root@$IP NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root /mnt -- /run/current-system/bin/switch-to-configuration boot
    ssh -o StrictHostKeyChecking=no root@$IP reboot
  '';

in
{

  environment.systemPackages = with pkgs; [ install-aarch64 gh ];

  programs.ssh = {
    extraConfig = ''
      Host tmp-install
        HostName tmp-install.mlyxshi.com
        User root
        ProxyCommand ${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h
        StrictHostKeyChecking no
        IdentityFile /secret/ssh/github
    '';
  };

}
