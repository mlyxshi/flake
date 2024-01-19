{ plasma-manager, lib, ... }@args: {

  imports = [
    plasma-manager.homeManagerModules.plasma-manager
  ];

  home.file.".config/kate/lspclient/settings.json".text = ''
    {
      "servers": {
        "nix": {
          "command": ["nil"],
          "url": "https://github.com/oxalica/nil",
          "highlightingModeRegex": "^Nix$"
        }
      }
    }
  '';

  programs.plasma = {
    enable = true;
    shortcuts = {
      kwin = {
        "Walk Through Windows" = [ "Meta+Tab" ];
        "Cycle Overview" = ""; #default: Meta+Tab
        "Overview" = ""; #default: Meta+W
      };

      "plasmashell"."manage activities" = ""; #default: Meta+Q

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
