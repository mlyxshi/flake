{ config, pkgs, lib, modulesPath, ... }:
let
  rootPartType = {
    x64 = "4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709";
    aa64 = "B921B045-1DF0-41C3-AF44-4C6F280D3FAE";
  }.${pkgs.stdenv.hostPlatform.efiArch};
in {

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

  boot.initrd.systemd.storePaths = [
    "${pkgs.ncurses}/share/terminfo/"
  ]; # add terminfo for better ssh experience

  boot.initrd.systemd.contents = {
    "/etc/hostname".text = ''
      ${config.networking.hostName}
    '';
    "/etc/ssl/certs/ca-certificates.crt".source =
      "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    "/etc/nix/nix.conf".text = ''
      extra-experimental-features = nix-command flakes
      substituters = https://cache.nixos.org
      trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
    '';
  };

  # Real cloud provider(Oracle/Azure): device name is sda
  # Qemu local test: Paravirtualization, device name is vda (-drive file=disk.img,format=qcow2,if=virtio)
  # This udev rule symlinks vda to sda to unify device name.
  boot.initrd.services.udev.rules = ''
    KERNEL=="vda*", SYMLINK+="sda%n"
  '';

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

    # File explorer and editor for debugging
    r = "${pkgs.joshuto}/bin/joshuto";
    hx = "${pkgs.helix}/bin/hx";

    # https://superuser.com/questions/1572410/what-is-the-purpose-of-the-linux-home-partition-code-8302
    make-partitions = pkgs.writeScript "make-partitions" ''
      sgdisk --zap-all /dev/sda
      sgdisk --new=0:0:+512M --typecode=0:ef00 /dev/sda
      sgdisk --new=0:0:0 --typecode=0:${rootPartType} /dev/sda
    '';

    mount-partitions = pkgs.writeScript "mount-partitions" ''
      mkfs.fat -F 32 /dev/sda1
      mkfs.ext4 -F /dev/sda2
      mkdir -p /mnt
      mount /dev/sda2 /mnt
      mount --mkdir /dev/sda1 /mnt/boot
    '';

    get-kernel-param = pkgs.writeScript "get-kernel-param" ''
      for o in $(< /proc/cmdline); do
          case $o in
              $1=*)
                  echo "''${o#"$1="}"
                  ;;
          esac
      done
    '';
  };

  # move everything in / to /sysroot and switch-root into it. 
  # This runs a few things twice and wastes some memory
  # but is necessary for [nix --store flag / nixos-enter] as pivot_root does not work on rootfs.
  boot.initrd.systemd.services.remount-root = {
    before = [ "initrd-fs.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ls -l /
      root_fs_type="$(mount|awk '$3 == "/" { print $1 }')"
      if [ "$root_fs_type" != "tmpfs" ]; then
        cp -R /init /bin /etc /lib /nix /root /sbin /var /sysroot
        mkdir -p /sysroot/tmp
        systemctl --no-block switch-root /sysroot /bin/init
      fi
    '';
    requiredBy = [ "initrd-fs.target" ];
  };

  boot.initrd.systemd.emergencyAccess = true;
  # Uncomment for debugging in local qemu

  # https://systemd-by-example.com/
  # https://www.freedesktop.org/software/systemd/man/latest/bootup.html
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/systemd/initrd.nix
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/initrd-ssh.nix
  # boot.initrd.systemd.services.force-fail = {
  #   # Order this after sshd, so that we can also ssh into the kexec environment.
  #   after = [ "initrd-fs.target" "sshd.service" ];
  #   # Force initrd.target failed with result 'dependency'. So that we can get emergency shell for debugging
  #   before = [ "initrd.target" ];
  #   serviceConfig.Type = "oneshot";
  #   serviceConfig.ExecStart = "/bin/false";
  #   requiredBy = [ "initrd.target" ];
  # };

  # Disable default services in Nixpkgs
  boot.initrd.systemd.services.initrd-nixos-activation.enable = false;
  boot.initrd.systemd.services.initrd-switch-root.enable = false;

  boot.initrd.systemd.services.initrd-cleanup.enable = false;
  boot.initrd.systemd.services.initrd-parse-etc.enable = false;
}
