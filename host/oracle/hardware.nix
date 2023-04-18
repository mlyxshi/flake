{ modulesPath, pkgs, lib, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.systemd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.timeout = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  # Ampere A1[aarch64] 24G RAM
  # E2.1.Micro[x86_64] 1G RAM: use zram
  zramSwap.enable = pkgs.hostPlatform.isx86_64;
  zramSwap.memoryPercent = 300;
  boot.kernel.sysctl = lib.optionalAttrs pkgs.hostPlatform.isx86_64 {
    "vm.swappiness" = 100;
  };
}
