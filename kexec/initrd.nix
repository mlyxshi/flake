{ config, pkgs, lib, modulesPath, ... }:
let
  rootPartType = {
    x64 = "4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709";
    aa64 = "B921B045-1DF0-41C3-AF44-4C6F280D3FAE";
  }.${pkgs.stdenv.hostPlatform.efiArch};
in
{

  imports = [ ./initrd-network.nix ];

  boot.initrd.systemd.enable = true;

  # hyperv = [ "hv_balloon" "hv_netvsc" "hv_storvsc" "hv_utils" "hv_vmbus" ];
  # add extra kernel modules: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/all-hardware.nix

  # NixOS also include default kernel modules: https://github.com/NixOS/nixpkgs/blob/660e7737851506374da39c0fa550c202c824a17c/nixos/modules/system/boot/kernel.nix#L214
  # boot.initrd.includeDefaultModules = false;
  boot.initrd.kernelModules = [
    #qemu 
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
    # ext4
    "ext4"
    # vfat
    "vfat"
    "nls_cp437"
    "nls_iso8859-1"
  ];

  boot.initrd.systemd.initrdBin = [ pkgs.dosfstools pkgs.e2fsprogs ];

  boot.initrd.systemd.contents = {
    "/etc/hostname".text = "systemd-initrd";
    "/etc/ssl/certs/ca-certificates.crt".source = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    "/etc/ssh/ssh_known_hosts".text = "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    "/etc/ssh/ssh_config".text = ''
      Host github.com
        User git
        IdentityFile /etc/ssh/github
    '';
    "/etc/nix/nix.conf".text = ''
      extra-experimental-features = nix-command flakes
      substituters = https://cache.nixos.org
      trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
    '';
  };

  boot.initrd.systemd.storePaths = [
    "${pkgs.ncurses}/share/terminfo/" # add terminfo for better ssh experience
    # "${pkgs.git}/share/git-core/templates" # add git templates
  ];

  boot.initrd.systemd.extraBin = {
    # nix & installer
    nix = "${pkgs.nix}/bin/nix";
    nix-store = "${pkgs.nix}/bin/nix-store";
    nix-env = "${pkgs.nix}/bin/nix-env";
    busybox = "${pkgs.busybox-sandbox-shell}/bin/busybox";
    nixos-enter = "${pkgs.nixos-install-tools}/bin/nixos-enter";
    unshare = "${pkgs.util-linux}/bin/unshare";

    ssh-keygen = "${config.programs.ssh.package}/bin/ssh-keygen";
    awk = "${pkgs.gawk}/bin/awk";
    sgdisk = "${pkgs.gptfdisk}/bin/sgdisk";
    lsblk = "${pkgs.util-linux}/bin/lsblk";
    curl = "${pkgs.curl}/bin/curl";
    htop = "${pkgs.htop}/bin/htop";
    ip = "${pkgs.iproute2}/bin/ip";
    git = "${pkgs.gitMinimal}/bin/git";
    ssh = "${config.programs.ssh.package}/bin/ssh";

    # File explorer and editor for debugging
    r = "${pkgs.joshuto}/bin/joshuto";
    hx = "${pkgs.helix}/bin/hx";

    get-kernel-param = pkgs.writeScript "get-kernel-param" ''
      for o in $(< /proc/cmdline); do
        case $o in
          $1=*)
            echo "''${o#"$1="}"
            ;;
        esac
      done
    '';

    # https://superuser.com/questions/1572410/what-is-the-purpose-of-the-linux-home-partition-code-8302
    make-partitions = pkgs.writeScript "make-partitions" ''
      DEVICE=$1 
      sgdisk --zap-all $DEVICE 
      sgdisk --new=0:0:+512M --typecode=0:ef00 $DEVICE
      sgdisk --new=0:0:0 --typecode=0:${rootPartType} $DEVICE
    '';

    mount-partitions = pkgs.writeScript "mount-partitions" ''
      DEVICE=$1 
      mkfs.fat -F 32 $DEVICE"1"
      mkfs.ext4 -F $DEVICE"2"
      mkdir -p /mnt
      mount $DEVICE"2" /mnt
      mount --mkdir $DEVICE"1" /mnt/boot
    '';
  };

  # move everything in / to /sysroot and switch-root into it. 
  # This runs systemd initrd twice
  # but it is necessary for [nix --store flag / nixos-enter] as pivot_root does not work on rootfs.
  boot.initrd.systemd.services.remount-root = {
    after = [ "sysroot.mount" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ls -l /
      root_fs_type="$(mount|awk '$3 == "/" { print $1 }')"
      if [ "$root_fs_type" != "tmpfs" ]; then
        cp -R /init /bin /etc /lib /nix /root /sbin /var /sysroot
        mkdir -p /sysroot/tmp
        systemctl --no-block switch-root
      fi
    '';
    requiredBy = [ "sysroot.mount" ];
  };

  boot.initrd.systemd.services.github-private-key = {
    unitConfig.ConditionKernelCommandLine = "github-private-key";
    unitConfig.ConditionPathExists = "!/etc/ssh/github";
    serviceConfig.Type = "oneshot";
    script = ''
      get-kernel-param github-private-key | base64 -d > /etc/ssh/github
      chmod 600 /etc/ssh/github
    '';
    requiredBy = [ "initrd.target" ];
  };

  boot.initrd.systemd.emergencyAccess = true;
  
  boot.initrd.systemd.services.initrd-find-nixos-closure.enable = false;

  # https://www.freedesktop.org/software/systemd/man/latest/bootup.html#Bootup%20in%20the%20initrd
  # Disable: initrd-parse-etc.service -> initrd-cleanup.service -> initrd-switch-root.target
  # so this initrd will stop at initrd.target
  boot.initrd.systemd.services.initrd-parse-etc.enable = false;
}
