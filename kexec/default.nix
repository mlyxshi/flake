{ config, pkgs, lib, ... }: {
  system.stateVersion = lib.trivial.release;
  networking.hostName = "systemd-initrd";

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.network.enable = true;
  boot.initrd.systemd.network.networks.ethernet-default-dhcp = {
    matchConfig = { Name = [ "en*" "eth*" ]; };
    networkConfig = { DHCP = "yes"; };
  };

  boot.initrd.network.ssh.enable = true;
  boot.initrd.systemd.services.sshd.preStart = lib.mkForce "/bin/chmod 0600 /etc/ssh/ssh_host_ed25519_key";

  # qemu + ext4 + vfat + efivarfs + overlayfs
  # add extra kernel modules: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/all-hardware.nix
  boot.initrd.kernelModules = [ "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "virtio_balloon" "virtio_console" ]
    ++ [ "ext4" ]
    ++ [ "vfat" "nls_cp437" "nls_iso8859-1" ]
    ++ [ "efivarfs" ]
    ++ [ "erofs" "overlay" ];

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
      cd /
    '';
  };

  boot.initrd.systemd.storePaths = [
    "${pkgs.file}" # yazi dependency 
    "${pkgs.ncurses}/share/terminfo/" # add terminfo for better ssh experience
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

    # fs
    "mkfs.fat" = "${pkgs.dosfstools}/bin/mkfs.fat";
    "mkfs.ext4" = "${pkgs.e2fsprogs}/sbin/mkfs.ext4";
    sgdisk = "${pkgs.gptfdisk}/bin/sgdisk"; # GPT
    parted = "${pkgs.parted}/bin/parted"; # MBR
    file = "${pkgs.file}/bin/file";
    lsblk = "${pkgs.util-linux}/bin/lsblk";

    # debug
    htop = "${pkgs.htop}/bin/htop";
    yazi = "${pkgs.yazi-unwrapped}/bin/yazi";
    hx = "${pkgs.helix}/bin/hx";
  };

  boot.initrd.systemd.emergencyAccess = true;

  boot.initrd.systemd.services.initrd-find-nixos-closure.enable = false;

  # https://www.freedesktop.org/software/systemd/man/latest/bootup.html#Bootup%20in%20the%20initrd
  # Disable: initrd-parse-etc.service -> initrd-cleanup.service -> initrd-switch-root.target
  # so systemd will stop at initrd.target
  boot.initrd.systemd.services.initrd-parse-etc.enable = false;
}


# rd.systemd.break=pre-switch-root 
