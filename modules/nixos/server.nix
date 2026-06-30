{
  pkgs,
  lib,
  config,
  self,
  modulesPath,
  ...
}:
{

  imports = [
    self.nixosModules.nixos.base
    "${modulesPath}/profiles/perlless.nix"
    "${modulesPath}/profiles/minimal.nix"
  ];

  environment.systemPackages = with pkgs; [
    iperf
    nexttrace
    ookla-speedtest
    fastfetch-unwrapped
  ];

  system.etc.overlay.mutable = false;

  environment.variables.BROWSER = "echo"; # Print the URL instead on servers

  networking.domain = "mlyxshi.com";

  fonts.fontconfig.enable = false;
}
