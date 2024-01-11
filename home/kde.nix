{ plasma-manager, lib, ... }@args: {

  imports = [
    plasma-manager.homeManagerModules.plasma-manager
  ];

  programs.plasma = {
    enable = true;
    # In NixOS, use xremap to remap Application specific key, use kde global shortcuts for system-window-switching
    # In non-NixOS, use toshy, which already handles the remap of system-window-switching
    shortcuts = {
      kwin = lib.mkIf (args ? osConfig) {
        "Walk Through Windows" = [ "Meta+Tab" ];
        "Cycle Overview" = ""; # avoid collision
      };

      "org.kde.krunner.desktop"."_launch" = [ "Alt+Space" "Meta+Space" "Search" ];

    };


    panels = [
      {
        location = "bottom";
        hiding = "autohide";
        widgets = [
          "org.kde.plasma.icontasks"
        ];
      }
      # MacOS like top bar
      {
        location = "top";
        height = 26;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.appmenu"
          "org.kde.plasma.panelspacer"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];

    dataFile = {
      "konsole/fish.profile" = {
        "General"."Command" = "fish";
        "General"."Name" = "fish";
      };
    };

    configFile = {
      "konsolerc"."Desktop Entry"."DefaultProfile" = "fish.profile";
    };

  };

}
