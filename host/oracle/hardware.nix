{ modulesPath, pkgs, lib, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.systemd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.timeout = 3;
  boot.loader.efi.canTouchEfiVariables = true;


  services.zram-generator = {
    enable = pkgs.hostPlatform.isx86_64;
    settings.zram0 = {
      compression-algorithm = "zstd";
      zram-size = "2*ram";
    };
  };

  boot.kernel.sysctl = lib.optionalAttrs pkgs.hostPlatform.isx86_64 {
    "vm.swappiness" = 100;
  };
}
