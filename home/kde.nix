{ plasma-manager, ... }: {

  imports = [
    plasma-manager.homeManagerModules.plasma-manager
  ];

  # MacOS-like window switching
  programs.plasma = {
    enable = true;
    shortcuts.kwin = {
      "Walk Through Windows" = "Meta+Tab";
      "Cycle Overview" = ""; # avoid collision
    };
  };

}
