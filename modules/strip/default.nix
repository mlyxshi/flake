# Remove and disable unnecessary modules
{ pkgs, lib, config, ... }: {
  # dummy options to make other modules happy
  options.services.lvm.enable = lib.mkEnableOption "lvm";
  options.boot.initrd.services.lvm.enable = lib.mkEnableOption "lvm";

  # https://nixos.org/manual/nixos/unstable/#sec-replace-modules
  disabledModules = [
    "tasks/lvm.nix"
    "tasks/bcache.nix"

    "programs/nano.nix"
  ];

  imports = [
  ];

  config = {
    # Disable security features
    boot.initrd.systemd.enableTpm2 = false;

    nixpkgs.overlays = [
      (final: prev: {
        # systemdStage1 is nomarlly used in the initrd
        # systemdStage1Network is only used when "boot.initrd.systemd.network = true;" [ only used in the my nixos kexec's initrd(For VPS first intall)]
        # initrd without security stuff will be very small and lightweight
        systemdStage1Network = prev.systemdStage1Network.override {
          withCryptsetup = false;
          withFido2 = false;
          withTpm2Tss = false;
        };
      })
    ];
  };
}
