# personal usage
{ pkgs, lib, config, ... }:
let
  installScript = ''
    flake=$(get-kernel-param flake)
    [ ! -n "$flake" ] && flake="github:mlyxshi/flake"                     # convenient for myself
    
    host=$(get-kernel-param host)
    if [ -n "$host" ]
    then
      echo "Nix will build: $flake#nixosConfigurations.$host.config.system.build.toplevel"
    else
      echo "No host defined for auto-installer"
      exit 1
    fi

    # add extra 1G memory for evaluate nix config
    echo 1G > /sys/block/zram0/disksize
    mkswap /dev/zram0
    swapon /dev/zram0

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
    
    nix build -L --store /mnt --profile /mnt/nix/var/nix/profiles/system $flake#nixosConfigurations.$host.config.system.build.toplevel
    
    mkdir -p /mnt/{etc,tmp}
    touch /mnt/etc/NIXOS
    [[ -n "$age_key" ]] && mkdir -p /mnt/persist/age/ && curl -sLo /mnt/persist/age/sshkey $age_key
    mkdir -p /mnt/persist/etc/ssh && for i in /etc/ssh/ssh_host_ed25519_key*; do cp $i /mnt/persist/etc/ssh; done
    
    # support UEFI systemd-boot
    mount -t efivarfs efivarfs /sys/firmware/efi/efivars

    NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root /mnt -- /run/current-system/bin/switch-to-configuration boot

    [[ -n "$bark_key" ]] && curl https://api.day.app/$bark_key/NixOS%20Install%20Done/$host?icon=https://nixos.org/favicon.ico
        
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
    environment.HOME = "/root";
    script = installScript;
    requiredBy = [ "initrd.target" ];
  };

}
