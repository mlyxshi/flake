{ home-manager, ... }: {
  imports = [
    home-manager.nixosModules.default
  ];

  home-manager.sharedModules = [
    ../../home
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.verbose = true;
}
