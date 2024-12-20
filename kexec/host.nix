{ config, pkgs, lib, ... }: {
  # prepare /sysroot for switch-root
  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "mode=0755" ];
  };

  system.stateVersion = lib.trivial.release;

  system.build.kexec = pkgs.runCommand "" { } ''
    mkdir -p $out
    ln -s ${config.system.build.initialRamdisk}/initrd $out/initrd
    ln -s ${config.system.build.kernel}/${pkgs.hostPlatform.linux-kernel.target} $out/kernel
    ln -s ${pkgs.pkgsStatic.kexec-tools}/bin/kexec $out/kexec
  '';


  boot.kernelPatches = [
    # https://nixos.wiki/wiki/Linux_kernel#Too_high_ram_usage
    # https://github.com/torvalds/linux/blob/master/arch/arm64/configs/virt.config
    {
      name = "qemu-only";
      patch = null;
      extraStructuredConfig = with lib.kernel;{
        # Base options for platforms
        ARCH_ACTIONS = lib.mkForce no;
        ARCH_SUNXI = lib.mkForce no;
        ARCH_ALPINE = lib.mkForce no;
        ARCH_APPLE = lib.mkForce no;
        ARCH_BCM = lib.mkForce no;
        ARCH_BCM2835 = lib.mkForce no;
        ARCH_BCMBCA = lib.mkForce no;
        ARCH_BCM_IPROC = lib.mkForce no;
        ARCH_BERLIN = lib.mkForce no;
        ARCH_BRCMSTB = lib.mkForce no;
        ARCH_EXYNOS = lib.mkForce no;
        ARCH_SPARX5 = lib.mkForce no;
        ARCH_K3 = lib.mkForce no;
        ARCH_LAYERSCAPE = lib.mkForce no;
        ARCH_LG1K = lib.mkForce no;
        ARCH_HISI = lib.mkForce no;
        ARCH_KEEMBAY = lib.mkForce no;
        ARCH_MEDIATEK = lib.mkForce no;
        ARCH_MESON = lib.mkForce no;
        ARCH_MVEBU = lib.mkForce no;
        ARCH_NXP = lib.mkForce no;
        ARCH_MA35 = lib.mkForce no;
        ARCH_MXC = lib.mkForce no;
        ARCH_NPCM = lib.mkForce no;
        ARCH_QCOM = lib.mkForce no;
        ARCH_REALTEK = lib.mkForce no;
        ARCH_RENESAS = lib.mkForce no;
        ARCH_ROCKCHIP = lib.mkForce no;
        ARCH_S32 = lib.mkForce no;
        ARCH_SEATTLE = lib.mkForce no;
        ARCH_INTEL_SOCFPGA = lib.mkForce no;
        ARCH_STM32 = lib.mkForce no;
        ARCH_SYNQUACER = lib.mkForce no;
        ARCH_TEGRA = lib.mkForce no;
        ARCH_TESLA_FSD = lib.mkForce no;
        ARCH_SPRD = lib.mkForce no;
        ARCH_THUNDER = lib.mkForce no;
        ARCH_THUNDER2 = lib.mkForce no;
        ARCH_UNIPHIER = lib.mkForce no;
        ARCH_VEXPRESS = lib.mkForce no;
        ARCH_VISCONTI = lib.mkForce no;
        ARCH_XGENE = lib.mkForce no;
        ARCH_ZYNQMP = lib.mkForce no;

        # Subsystems which can't be used in mach-virt
        CHROME_PLATFORMS = lib.mkForce no;
        EXTCON = lib.mkForce no;
        IIO = lib.mkForce no;
        MTD = lib.mkForce no;
        NEW_LEDS = lib.mkForce no;
        PWM = lib.mkForce no;
        REGULATOR = lib.mkForce no;
        SLIMBUS = lib.mkForce no;
        SND_SOC = lib.mkForce no;
        SOUNDWIRE = lib.mkForce no;
        SPI = lib.mkForce no;
        SURFACE_PLATFORMS = lib.mkForce no;
        THERMAL = lib.mkForce no;
      };
    }
  ];
}
