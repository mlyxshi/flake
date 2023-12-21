{ config, lib, pkgs, self, ... }: {
  networking.hostName = "asahi";

  # KDE Plasma Desktop network management
  networking.networkmanager.enable = true;


  nixpkgs.overlays = [ self.overlays.default ];

}


