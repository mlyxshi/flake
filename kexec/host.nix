{ config, pkgs, lib, ... }: {
  imports = [
    ./strip.nix
  ];
  
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  networking = {
    hostName = "systemd-stage1";
    usePredictableInterfaceNames = false;
  };

  system.stateVersion = lib.trivial.release;

  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "mode=0755" ];
  };

  boot.loader.grub.enable = false;
  boot.kernelParams = [
    "systemd.show_status=true"
    "systemd.log_level=info"
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
