{ config, pkgs, lib, ... }: {
  imports = [
    ./install.nix
    ./network.nix
    ./kernelModules.nix
  ];

  boot.initrd.systemd.contents = {
    "/etc/hostname".text = "${config.networking.hostName}\n";
    "/etc/resolv.conf".text = "nameserver 1.1.1.1\n";
    "/etc/ssl/certs/ca-certificates.crt".source = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    "/etc/nix/nix.conf".text = ''
      extra-experimental-features = nix-command flakes auto-allocate-uids
      auto-allocate-uids = true
      substituters = https://cache.nixos.org https://cache.mlyxshi.com
      trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache:vXjiuWtSTOXj63zr+ZjMvXqvaYIK1atjyyEk+iuIqSg=
    '';

    "/etc/lf/lfrc".text = ''
      set hidden true
      set number true
      set drawbox true
      set dircounts true
      set incsearch true
      set period 1
      map Q   quit
      map D   delete
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
    lf = "${pkgs.lf}/bin/lf";

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
  # but is necessary for nix --store flag as pivot_root does not work on rootfs.
  boot.initrd.systemd.services.remount-root = {
    before = [ "initrd-fs.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ls -l /
      root_fs_type="$(mount|awk '$3 == "/" { print $1 }')"
      if [ "$root_fs_type" != "tmpfs" ]; then
        cp -R /init /bin /etc /lib /nix /root /sbin /var  /sysroot
        mkdir -p /sysroot/tmp
        systemctl --no-block switch-root /sysroot /bin/init
      fi
    '';
    requiredBy = [ "initrd-fs.target" ];
  };


  # Disable default services in Nixpkgs
  boot.initrd.systemd.services.initrd-nixos-activation.enable = false;
  boot.initrd.systemd.services.initrd-switch-root.enable = false;
  # keep in stage 1
  boot.initrd.systemd.services.initrd-cleanup.enable = false;
  boot.initrd.systemd.services.initrd-parse-etc.enable = false;



  # When these are enabled, they prevent useful output from going to the console
  boot.initrd.systemd.paths.systemd-ask-password-console.enable = false;
  boot.initrd.systemd.services.systemd-ask-password-console.enable = false;
}
