{ config, pkgs, lib, self, ... }:
let
  install-aarch64 = pkgs.writeShellScriptBin "install-aarch64" ''
    HOST=$1
    IP=$2
    AGE_KEY_URL=$3
    BARK_KEY=$4

    [[ -e "/persist/flake/flake.nix" ]] || git clone --depth=1  git@github.com:mlyxshi/flake /persist/flake
      
    cd /persist/flake
    git pull 

    outPath=$(nix build --no-link --print-out-paths .#nixosConfigurations.$HOST.config.system.build.toplevel)
    
    # ssh -o StrictHostKeyChecking=no root@$IP
    # while test $? -gt 0
    # do
    #   sleep 5 
    #   echo "Wait kexec loading and ssh server, Trying again..."
    #   ssh -o StrictHostKeyChecking=no root@$IP
    # done

    # until ssh -o StrictHostKeyChecking=no root@$IP 2> /dev/null
    # do
    #   echo "Wait kexec loading and ssh server, Trying again..."
    #   sleep 5
    # done

    ssh -o StrictHostKeyChecking=no root@$IP parted --script /dev/sda mklabel gpt mkpart "BOOT" fat32  1MiB  512MiB mkpart "NIXOS" ext4 512MiB 100% set 1 esp on
    ssh -o StrictHostKeyChecking=no root@$IP mkfs.fat -F 32 /dev/disk/by-partlabel/BOOT
    ssh -o StrictHostKeyChecking=no root@$IP mkfs.ext4 -F /dev/disk/by-partlabel/NIXOS
    ssh -o StrictHostKeyChecking=no root@$IP mkdir -p /mnt
    ssh -o StrictHostKeyChecking=no root@$IP mount /dev/disk/by-partlabel/NIXOS /mnt
    ssh -o StrictHostKeyChecking=no root@$IP mount --mkdir /dev/disk/by-partlabel/BOOT /mnt/boot

    NIX_SSHOPTS='-o StrictHostKeyChecking=no' nix copy --substitute-on-destination --to ssh://root@$IP?remote-store=local?root=/mnt $outPath       

    ssh -o StrictHostKeyChecking=no root@$IP nix-env --store /mnt -p /mnt/nix/var/nix/profiles/system --set $outPath
    ssh -o StrictHostKeyChecking=no root@$IP mkdir /mnt/{etc,tmp}
    ssh -o StrictHostKeyChecking=no root@$IP touch /mnt/etc/NIXOS
    ssh -o StrictHostKeyChecking=no root@$IP mkdir -p /mnt/persist/sops/ 
    ssh -o StrictHostKeyChecking=no root@$IP curl -sLo /mnt/persist/sops/key $AGE_KEY_URL
    ssh -o StrictHostKeyChecking=no root@$IP NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root /mnt -- /run/current-system/bin/switch-to-configuration boot
    ssh -o StrictHostKeyChecking=no root@$IP reboot

    curl https://api.day.app/$BARK_KEY/NixOS%20Install%20Done/$HOST?icon=https://hydra.nixos.org/logo

  '';
in

{

  environment.systemPackages = [
    install-aarch64
  ];

}
