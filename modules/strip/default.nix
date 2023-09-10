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

    # I like minimal initrd, so kexec's initrd will be very small and lightweight
    nixpkgs.overlays = [
      (final: prev: {
        systemdStage1 = prev.systemdStage1.override {
          withCryptsetup = false;
          withFido2 = false;
          withTpm2Tss = true;
        };
      })
    ];
  };
}
