{ pkgs, lib, config, self, ... }: {

  imports = [
    self.nixosModules.nixos.base
  ];


  environment.systemPackages = with pkgs;[
    iperf
    mtr
    ookla-speedtest
  ];

  # systemd.sysusers.enable = true;
  # system.etc.overlay.enable = true;

  fonts.fontconfig.enable = false;

  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  # https://github.com/NixOS/nixpkgs/pull/104828
  system.disableInstallerTools = true;
  boot.enableContainers = false;
  environment.defaultPackages = [ ];
}
