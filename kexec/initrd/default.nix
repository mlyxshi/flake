{ config, pkgs, lib, ... }: {
  imports = [
    ./network.nix
    ./kernelModules.nix
  ];

  boot.initrd.systemd.contents = {
    "/etc/hostname".text = "${config.networking.hostName}\n";
    "/etc/resolv.conf".text = "nameserver 1.1.1.1\n";
    "/etc/ssl/certs/ca-certificates.crt".source = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
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
    busybox = "${pkgs.busybox-sandbox-shell}/bin/busybox";
    ssh-keygen = "${config.programs.ssh.package}/bin/ssh-keygen";
    lsblk = "${pkgs.util-linux}/bin/lsblk";
    curl = "${pkgs.curl}/bin/curl";
    gzip = "${pkgs.gzip}/bin/gzip";

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
