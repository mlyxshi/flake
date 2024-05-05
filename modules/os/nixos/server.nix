{ pkgs, lib, config, self, ... }: {

  imports = [
    self.nixosModules.os.nixos.base
  ];

  # systemd.sysusers.enable = true;
  # system.etc.overlay.enable = true;

  # fonts.fontconfig.enable = false;
  environment.noXlibs = true;

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
