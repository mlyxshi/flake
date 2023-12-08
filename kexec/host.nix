{ config, pkgs, lib, ... }: {
  time.timeZone = "UTC";
  networking.hostName = "systemd-initrd";

  system.stateVersion = lib.trivial.release;

  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "mode=0755" ];
  };

  boot.kernelParams = [
    "systemd.log_target=console"
    "systemd.journald.forward_to_console=1"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  fonts.fontconfig.enable = false;

  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };
}
