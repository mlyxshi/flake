{
  boot.initrd.kernelModules = [ "hv_balloon" "hv_netvsc" "hv_storvsc" "hv_utils" "hv_vmbus" ];

  boot.initrd.systemd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;

  zramSwap.enable = true;
  zramSwap.memoryPercent = 200;
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
  };

}
