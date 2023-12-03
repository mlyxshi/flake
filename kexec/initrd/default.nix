{ config, pkgs, lib, ... }: {
  imports = [
    #./network.nix
    ./kernelModules.nix
  ];

  boot.initrd.systemd.contents = {
    "/etc/hostname".text = "${config.networking.hostName}\n";
    "/etc/resolv.conf".text = "nameserver 1.1.1.1\n";
    "/etc/ssl/certs/ca-certificates.crt".source = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    "/etc/nix/nix.conf".text = ''
      extra-experimental-features = nix-command flakes auto-allocate-uids
      auto-allocate-uids = true
      substituters = https://cache.nixos.org
      trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
    '';
  };


  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  # Real cloud provider(Oracle/Azure): device name is sda
  # Qemu local test: Paravirtualization, device name is vda (-drive file=disk.img,format=qcow2,if=virtio)
  # This udev rule sysmlinks vda to sda so that the installer script can only use one device name.
  boot.initrd.services.udev.rules = ''
    KERNEL=="vda*", SYMLINK+="sda%n"
  '';

  # vfat and ext4
  boot.initrd.systemd.initrdBin = [ pkgs.dosfstools pkgs.e2fsprogs ];

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
    parted = "${pkgs.parted}/bin/parted";
    lsblk = "${pkgs.util-linux}/bin/lsblk";
    curl = "${pkgs.curl}/bin/curl";

    joshuto = "${pkgs.joshuto}/bin/joshuto";
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
  };

  # kexec initrd -> / filesystem is rootfs
  # However, when / filesystem is rootfs, we can not use pivot_root
  # nix --store flag requires chroot, chroot requires pivot_root 
  
  # Hacky way change / filesystem from rootfs to tmpfs
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/systemd/initrd.nix
  # https://www.freedesktop.org/software/systemd/man/latest/bootup.html
  boot.initrd.systemd.services.initrd-switch-root.preStart = ''
    root_fs_type="$(mount|awk '$3 == "/" { print $1 }')"
    if [ "$root_fs_type" != "tmpfs" ]; then
      cp -R /init /bin /etc /lib /nix /root /sbin /var /tmp  /sysroot
    else
      # when root fs is tmpfs, force stop endless switch-root loop, and get emergency shell for debugging
      exit 1
    fi
  '';

}
