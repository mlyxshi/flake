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

  # NixOS include default kernel modules which are unnecessary under qemu: https://github.com/NixOS/nixpkgs/blob/660e7737851506374da39c0fa550c202c824a17c/nixos/modules/system/boot/kernel.nix#L214
  boot.initrd.includeDefaultModules = false;

  # Only include required kernel modules
  boot.initrd.kernelModules = lib.mkForce [
    # vfat native language support are not build-in
    "nls_cp437"
    "nls_iso8859-1"
  ];

  boot.initrd.systemd.contents = {
    "/etc/ssl/certs/ca-certificates.crt".source = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    "/etc/ssh/ssh_known_hosts".text = "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    "/etc/ssh/ssh_config".text = ''
      Host github.com
        User git
        IdentityFile /run/credentials/@system/github-private-key
    '';
    "/etc/nix/nix.conf".text = ''
      extra-experimental-features = nix-command flakes
      substituters = https://cache.nixos.org
      trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
    '';
    # https://github.com/NixOS/nixpkgs/blob/3c6867e2f20b8584b03deb6d2b13d0ee0b4ad650/nixos/modules/config/users-groups.nix#L814
    "/etc/profile".text = ''
      PS1="\e[0;32m\]\u@\h \w >\e[0m\] "
      alias r='yazi'
      HOME="/root"
      cd /
    '';
  };

  boot.initrd.systemd.storePaths = [
    "${pkgs.ncurses}/share/terminfo/" # add terminfo for better ssh experience (htop)
  ];

  boot.initrd.systemd.extraBin = {
    # nix
    nix = "${pkgs.nix}/bin/nix";
    nix-store = "${pkgs.nix}/bin/nix-store";
    nix-env = "${pkgs.nix}/bin/nix-env";
    busybox = "${pkgs.busybox-sandbox-shell}/bin/busybox";
    nixos-enter = "${pkgs.nixos-install-tools}/bin/nixos-enter";
    unshare = "${pkgs.util-linux}/bin/unshare";

    # ssh
    git = "${pkgs.gitMinimal}/bin/git";
    ssh-keygen = "${config.programs.ssh.package}/bin/ssh-keygen";
    ssh = "${config.programs.ssh.package}/bin/ssh";

    # fs
    "mkfs.fat" = "${pkgs.dosfstools}/bin/mkfs.fat";
    "mkfs.ext4" = "${pkgs.e2fsprogs}/sbin/mkfs.ext4";
    sgdisk = "${pkgs.gptfdisk}/bin/sgdisk";
    lsblk = "${pkgs.util-linux}/bin/lsblk";

    # debug
    ip = "${pkgs.iproute2}/bin/ip";
    curl = "${pkgs.curl}/bin/curl";
    htop = "${pkgs.htop}/bin/htop";
    yazi = "${pkgs.yazi-unwrapped}/bin/yazi";
    hx = "${pkgs.helix}/bin/hx";

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
    unitConfig.ConditionKernelCommandLine = "!remount-root-disable";
    after = [ "sysroot.mount" ];
    serviceConfig.Type = "oneshot";
    script = ''
      root_fs_type="$(cat /proc/mounts | head -n 1 | cut -d ' ' -f 1)"
      if [ "$root_fs_type" != "tmpfs" ]; then
        cp -R /init /bin /etc /lib /nix /root /sbin /var /sysroot
        mkdir -p /sysroot/tmp
        systemctl --no-block switch-root
      fi
    '';
    requiredBy = [ "sysroot.mount" ];
  };

  boot.initrd.systemd.emergencyAccess = true;

  boot.initrd.systemd.services.initrd-find-nixos-closure.enable = false;

  # https://www.freedesktop.org/software/systemd/man/latest/bootup.html#Bootup%20in%20the%20initrd
  # Disable: initrd-parse-etc.service -> initrd-cleanup.service -> initrd-switch-root.target
  # so systemd will stop at initrd.target
  boot.initrd.systemd.services.initrd-parse-etc.enable = false;
}
