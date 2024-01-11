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
        "Walk Through Windows" = "Meta+Tab";
        "Cycle Overview" = ""; # avoid collision
      };

      "org.kde.krunner.desktop"."_launch" = [ "Alt+Space" "Meta+Space" "Search" ];

    };


    panels = [
      # Windows-like panel at the bottom
      {
        location = "bottom";
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marignsseperator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
      # Global menu at the top
      {
        location = "top";
        height = 26;
        widgets = [
          "org.kde.plasma.appmenu"
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
