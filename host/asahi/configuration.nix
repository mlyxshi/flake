{ config, lib, pkgs, self, nixos-apple-silicon, ... }: {
  networking.hostName = "asahi";

  # KDE Plasma Desktop Network Management
  networking.networkmanager.enable = true;

  sound.enable = true;


  nixpkgs.overlays = [ 
    self.overlays.default
    nixos-apple-silicon.overlays.default
  ];
}

