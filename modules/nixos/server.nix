{ pkgs, lib, config, self, ... }: {

  imports = [
    self.nixosModules.nixos.base
  ];


  environment.systemPackages = with pkgs;[
    iperf
    nexttrace
    ookla-speedtest
  ];

  environment.variables.BROWSER = "echo"; # Print the URL instead on servers

  networking.domain = "mlyxshi.com";

  fonts.fontconfig.enable = false;

  xdg.autostart.enable = false;
  xdg.icons.enable = false;
  xdg.menus.enable = false;
  xdg.mime.enable = false;
  xdg.sounds.enable = false;

  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  # perlless
  systemd.sysusers.enable = true;
  system.etc.overlay.enable = true;

  system.disableInstallerTools = true;
  environment.defaultPackages = [ ];
}
