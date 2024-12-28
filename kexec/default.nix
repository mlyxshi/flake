{ config, pkgs, lib, ... }: {
  system.stateVersion = lib.trivial.release;

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.network.enable = true;

  boot.initrd.network.ssh.enable = true;
  boot.initrd.systemd.services.sshd.preStart = lib.mkForce "/bin/chmod 0600 /etc/ssh/ssh_host_ed25519_key";

  # NixOS include default kernel modules which are unnecessary under qemu: https://github.com/NixOS/nixpkgs/blob/660e7737851506374da39c0fa550c202c824a17c/nixos/modules/system/boot/kernel.nix#L214
  boot.initrd.includeDefaultModules = false;

  # Only include required kernel modules [NOT BUILD-IN]
  boot.initrd.kernelModules = lib.mkForce [
    # vfat native language support
    "nls_cp437"
    "nls_iso8859-1"
    # Oracle cloud
    "virtio_scsi" # https://www.qemu.org/2021/01/19/virtio-blk-scsi-configuration/
  ];

  boot.initrd.systemd.contents = {
    "/etc/ssl/certs/ca-certificates.crt".source = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    "/etc/ssh/authorized_keys.d/root".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe";
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/keys
    "/etc/ssh/ssh_host_ed25519_key.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBWcxb/Blaqt1auOtE+F8QUWrUotiC5qBJ+UuEWdVCb";
    "/etc/ssh/ssh_host_ed25519_key".text = ''
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
      QyNTUxOQAAACCQVnMW/wZWqrdWrjrRPhfEFFq1KLYguagSflLhFnVQmwAAAJASuMMnErjD
      JwAAAAtzc2gtZWQyNTUxOQAAACCQVnMW/wZWqrdWrjrRPhfEFFq1KLYguagSflLhFnVQmw
      AAAEDIN2VWFyggtoSPXcAFy8dtG1uAig8sCuyE21eMDt2GgJBWcxb/Blaqt1auOtE+F8QU
      WrUotiC5qBJ+UuEWdVCbAAAACnJvb3RAbml4b3MBAgM=
      -----END OPENSSH PRIVATE KEY-----
    '';

    "/etc/ssh/ssh_known_hosts".text = "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    "/etc/ssh/ssh_config".text = ''
      Host github.com
        User git
        IdentityFile /run/credentials/github-private-key
    '';

    "/etc/nix/nix.conf".text = ''
      extra-experimental-features = nix-command flakes
      substituters = https://cache.nixos.org
      trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
    '';

    "/etc/yazi/yazi.toml".text = ''
      [manager]
      show_hidden = true
      linemode = "size"
    '';
    # https://github.com/NixOS/nixpkgs/blob/3c6867e2f20b8584b03deb6d2b13d0ee0b4ad650/nixos/modules/config/users-groups.nix#L814
    "/etc/profile".text = ''
      PS1="\e[0;32m\]\u@\h \w >\e[0m\] "
      alias r=yazi
      export HOME=/root
      export EDITOR=hx
      export YAZI_CONFIG_HOME=/etc/yazi
      export TERMINFO_DIRS=${pkgs.ghostty.terminfo}/share/terminfo
      cd /
    '';
  };

  boot.initrd.systemd.storePaths = [
    "${pkgs.file}" # yazi dependency 
    "${pkgs.ghostty.terminfo}/share/terminfo"
  ];

  boot.initrd.systemd.extraBin = {
    # nix
    nix = "${pkgs.nix}/bin/nix";
    nix-store = "${pkgs.nix}/bin/nix-store";
    nix-env = "${pkgs.nix}/bin/nix-env";
    busybox = "${pkgs.busybox-sandbox-shell}/bin/busybox";
    nixos-enter = "${pkgs.nixos-install-tools}/bin/nixos-enter";
    unshare = "${pkgs.util-linux}/bin/unshare";

    # net
    ip = "${pkgs.iproute2}/bin/ip";
    curl = "${pkgs.curl}/bin/curl";
    git = "${pkgs.gitMinimal}/bin/git";
    ssh = "${config.programs.ssh.package}/bin/ssh";

    # fs
    "mkfs.fat" = "${pkgs.dosfstools}/bin/mkfs.fat";
    "mkfs.ext4" = "${pkgs.e2fsprogs}/sbin/mkfs.ext4";
    sgdisk = "${pkgs.gptfdisk}/bin/sgdisk";
    file = "${pkgs.file}/bin/file";
    lsblk = "${pkgs.util-linux}/bin/lsblk";

    # debug
    htop = "${pkgs.htop}/bin/htop";
    yazi = "${pkgs.yazi-unwrapped}/bin/yazi";
    hx = "${pkgs.helix}/bin/hx";

    # https://superuser.com/questions/1572410/what-is-the-purpose-of-the-linux-home-partition-code-8302
    make-partitions =
      let
        rootPartType = {
          x64 = "4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709";
          aa64 = "B921B045-1DF0-41C3-AF44-4C6F280D3FAE";
        }.${pkgs.stdenv.hostPlatform.efiArch};
      in
      pkgs.writeScript "make-partitions" ''
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
  };

  # move everything in / to /sysroot and switch-root into it. 
  # This runs systemd initrd twice
  # but it is necessary for [nix --store flag / nixos-enter] as pivot_root does not work on rootfs.
  boot.initrd.systemd.services.remount-root = {
    unitConfig.ConditionKernelCommandLine = "systemd.mount-extra";
    after = [ "sysroot-run.mount" ]; # bind /run to /sysroot/run
    serviceConfig.Type = "oneshot";
    script = ''
      root_device_type="$(cat /proc/mounts | head -n 1 | cut -d ' ' -f 1)"
      if [ "$root_device_type" != "tmpfs" ]; then
        cp -R /init /bin /etc /lib /nix /root /sbin /var /sysroot
        cp /run/credentials/@system/github-private-key  /sysroot/run/credentials/
        mkdir -p /sysroot/tmp
        systemctl --no-block switch-root
      fi
    '';
    requiredBy = [ "initrd.target" ];
  };

  boot.initrd.systemd.emergencyAccess = true;

  boot.initrd.systemd.services.initrd-find-nixos-closure.enable = false;

  # https://www.freedesktop.org/software/systemd/man/latest/bootup.html#Bootup%20in%20the%20initrd
  # Disable: initrd-parse-etc.service -> initrd-cleanup.service -> initrd-switch-root.target
  # so systemd will stop at initrd.target
  boot.initrd.systemd.services.initrd-parse-etc.enable = false;
}
