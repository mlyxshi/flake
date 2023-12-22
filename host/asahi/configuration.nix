{ config, lib, pkgs, self, ... }: {
  networking.hostName = "asahi";

  # KDE Plasma Desktop Network Management
  networking.networkmanager.enable = true;


  nixpkgs.overlays = [ self.overlays.default ];
}

