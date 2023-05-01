{ pkgs, lib, config, self, ... }: {

  imports = [
    self.nixosModules.os.nixos.base
  ];

  fonts.fontconfig.enable = false;

  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };
}
