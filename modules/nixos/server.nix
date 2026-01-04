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
    autostart.enable = mkDefault false;
    icons.enable = mkDefault false;
    mime.enable = mkDefault false;
    sounds.enable = mkDefault false;
  };

  documentation = {
    enable = mkDefault false;
    doc.enable = mkDefault false;
    info.enable = mkDefault false;
    man.enable = mkDefault false;
    nixos.enable = mkDefault false;
  };



  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/perlless.nix
  systemd.sysusers.enable = true;
  system.etc.overlay.enable = true;

  system.tools.nixos-generate-config.enable = false;
  environment.defaultPackages = [ ];
  system.forbiddenDependenciesRegexes = [ "perl" ];
}
