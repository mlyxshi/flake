# personal usage
{ pkgs, lib, config, ... }:
let
  installScript = ''
    flake=$(get-kernel-param flake)
    [ ! -n "$flake" ] && flake="github:mlyxshi/flake"
    
    host=$(get-kernel-param host)

    if [ -n "$host" ]; then
      echo "host defined: $host"
    else
      echo "No host defined for auto-installer"
      exit 1
    fi

    bark_key=$(get-kernel-param bark_key)
    age_key=$(get-kernel-param age_key)
    local_test=$(get-kernel-param local_test)

    sfdisk /dev/sda <<EOT
    label: gpt
    type="EFI System",       name="BOOT",  size=512M
    type="Linux filesystem", name="NIXOS", size=+
    EOT

    sleep 2

    NIXOS=/dev/disk/by-partlabel/NIXOS
    BOOT=/dev/disk/by-partlabel/BOOT
    mkfs.fat -F 32 $BOOT
    mkfs.ext4 -F $NIXOS

    mkdir -p /mnt
    mount $NIXOS /mnt
    mount --mkdir $BOOT /mnt/boot

    echo "Nix will build: $flake#nixosConfigurations.$host.config.system.build.toplevel"
    nix build -L --store /mnt --profile /mnt/nix/var/nix/profiles/system $flake#nixosConfigurations.$host.config.system.build.toplevel 

    # Copy System Closure
    # system=$(curl -sL https://raw.githubusercontent.com/mlyxshi/install/main/$host)
    # echo "Nix will copy: $system from cache"
    # nix-env --store /mnt -p /mnt/nix/var/nix/profiles/system --set $system

    mkdir -p /mnt/{etc,tmp}
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
