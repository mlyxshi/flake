{ home-manager, ... }: {
  imports = [
    home-manager.nixosModules.default
  ];

  home-manager.users.dominic = import ../../home;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.verbose = true;
}
