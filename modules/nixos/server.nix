{
  pkgs,
  lib,
  config,
  self,
  ...
}:
{

  imports = [
    self.nixosModules.nixos.base
  ];

  environment.systemPackages = with pkgs; [
    iperf
    nexttrace
    ookla-speedtest
  ];

  environment.variables.BROWSER = "echo"; # Print the URL instead on servers

  networking.domain = "mlyxshi.com";

  fonts.fontconfig.enable = false;

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/minimal.nix
  xdg = {
    autostart.enable = false;
    icons.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };

  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };



  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/perlless.nix
  systemd.sysusers.enable = true;
  users.mutableUsers = false;
  system.etc.overlay.enable = true;

  system.tools.nixos-generate-config.enable = false;
  environment.defaultPackages = [ ];
  system.forbiddenDependenciesRegexes = [ "perl" ];
}
