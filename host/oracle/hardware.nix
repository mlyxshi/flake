{ modulesPath, pkgs, lib, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.systemd.enable = true;

  boot.initrd.systemd.root = "gpt-auto";
  boot.initrd.supportedFilesystems = [ "ext4" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.timeout = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernel.sysctl = {
    # 1000mbps bandwidth: socket receive/send buffer size 16 MB for hysteria2
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
  };
}
