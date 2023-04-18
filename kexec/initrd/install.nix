# personal usage
{ pkgs, lib, config, ... }:
let
  installScript = ''
    flake=$(get-kernel-param flake)
    [ ! -n "$flake" ] && flake="github:mlyxshi/flake"                     # convenient for myself
    
    host=$(get-kernel-param host)
    system=$(get-kernel-param system)

    if [ -n "$host" ]; then
      echo "Nix will build: $flake#nixosConfigurations.$host.config.system.build.toplevel"
    elif [ -n "$system" ]; then
      echo "Nix will copy $system from cache"
    else
      echo "No host defined for auto-installer"
      exit 1
    fi
  

    bark_key=$(get-kernel-param bark_key)
    age_key=$(get-kernel-param age_key)
    local_test=$(get-kernel-param local_test)

    parted --script /dev/sda \
    mklabel gpt \
    mkpart "BOOT"  fat32  1MiB    512MiB \
    mkpart "NIXOS" btrfs  512MiB  100% \
    set 1 esp on 

    sleep 2

    NIXOS=/dev/disk/by-partlabel/NIXOS
    BOOT=/dev/disk/by-partlabel/BOOT
    mkfs.fat -F 32 $BOOT
    mkfs.btrfs -f $NIXOS

    mkdir -p /fsroot
    mount $NIXOS /fsroot
    btrfs subvol create /fsroot/nix
    btrfs subvol create /fsroot/persist

    mkdir -p /mnt/{boot,nix,persist}
    mount $BOOT /mnt/boot
    mount -o subvol=nix,compress-force=zstd    $NIXOS /mnt/nix
    mount -o subvol=persist,compress-force=zstd $NIXOS /mnt/persist

    mkdir -p /mnt/{etc,tmp}
    
    if [ -n "$host" ]; then
      nix build -L --store /mnt --profile /mnt/nix/var/nix/profiles/system $flake#nixosConfigurations.$host.config.system.build.toplevel 
    fi

    if [ -n "$system" ]; then
      nix-env -p /mnt/nix/var/nix/profiles/system --set $system
    fi

    touch /mnt/etc/NIXOS
    [[ -n "$age_key" ]] && mkdir -p /mnt/persist/sops/ && curl -sLo /mnt/persist/sops/key $age_key
    mkdir -p /mnt/persist/etc/ssh && for i in /etc/ssh/ssh_host_ed25519_key*; do cp $i /mnt/persist/etc/ssh; done
    
    # support UEFI systemd-boot
    mount -t efivarfs efivarfs /sys/firmware/efi/efivars

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
