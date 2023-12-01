# personal usage
{ pkgs, lib, config, ... }:
let
  installScript = ''
    flake="github:mlyxshi/flake"
    
    host=$(get-kernel-param host)
    format=$(get-kernel-param format)

    if [ -n "$format" ]; then
      parted --script /dev/sda mklabel gpt mkpart "BOOT" fat32  1MiB  512MiB mkpart "NIXOS" ext4 512MiB 100% set 1 esp on

      sleep 2

      NIXOS=/dev/disk/by-partlabel/NIXOS
      BOOT=/dev/disk/by-partlabel/BOOT
      mkfs.fat -F 32 $BOOT
      mkfs.ext4 -F $NIXOS

      mkdir -p /mnt
      mount $NIXOS /mnt
      mount --mkdir $BOOT /mnt/boot
    else
      exit 1
    fi

    if [ -n "$host" ]; then
      echo "host defined: $host"
    else
      echo "No host defined for auto-installer"
      exit 1
    fi

    bark_key=$(get-kernel-param bark_key)
    age_key=$(get-kernel-param age_key)
    local_test=$(get-kernel-param local_test)


    if [ $(uname -m) = "aarch64" ]
    then
      # Oracle aarch64 machine: 4C24G, Build directly
      echo "Nix will build: $flake#nixosConfigurations.$host.config.system.build.toplevel"
      nix build -L --store /mnt --profile /mnt/nix/var/nix/profiles/system $flake#nixosConfigurations.$host.config.system.build.toplevel 
    else
      exit 1
    fi

    mkdir -p /mnt/{etc,tmp}
    touch /mnt/etc/NIXOS
    [[ -n "$age_key" ]] && mkdir -p /mnt/persist/sops/ && curl -sLo /mnt/persist/sops/key $age_key
    mkdir -p /mnt/persist/etc/ssh && for i in /etc/ssh/ssh_host_ed25519_key*; do cp $i /mnt/persist/etc/ssh; done
    

    NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root /mnt -- /run/current-system/bin/switch-to-configuration boot

    [[ -n "$bark_key" ]] && curl https://api.day.app/$bark_key/NixOS%20Install%20Done/$host?icon=https://hydra.nixos.org/logo
        
    # In local test, force exit 1 and use emergency shell to debug
    [[ -n "$local_test" ]] && exit 1 || reboot
  '';
in
{
  boot.initrd.systemd.services.auto-install = {
    requires = [ "network-online.target" ];
    after = [ "initrd-fs.target" "network-online.target" ];
    before = [ "initrd.target" ];
    serviceConfig.Type = "oneshot";
    script = installScript;
    requiredBy = [ "initrd.target" ];
  };
}
