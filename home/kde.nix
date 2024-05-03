{ plasma-manager, lib, config, ... }: {

  imports = [ plasma-manager.homeManagerModules.plasma-manager ];

  programs.plasma = {
    enable = true;
    shortcuts = {
      kwin = {
        "Walk Through Windows" = [ "Meta+Tab" ];
        "Cycle Overview" = ""; # default: Meta+Tab
        Overview = ""; # default: Meta+W
      };

      plasmashell."manage activities" = ""; # default: Meta+Q

      "org.kde.krunner.desktop"."_launch" =
        [ "Alt+Space" "Meta+Space" "Search" ];
    };

    panels = [
      {
        location = "bottom";
        floating = true;
        hiding = "autohide";
        widgets = [{
          name = "org.kde.plasma.icontasks";
          config = {
            General.launchers = [ "applications:systemsettings.desktop" ]
              ++ lib.optionals (config.home.username == "deck")
              [ "applications:org.kde.discover.desktop" ] ++ [
              "applications:org.kde.dolphin.desktop"
              "applications:org.kde.konsole.desktop"
              "applications:org.kde.kate.desktop"
              "applications:firefox.desktop"
            ] ++ lib.optionals (config.home.username == "deck")
              [ "applications:com.google.Chrome.desktop" ];
          };
        }];
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
        General.Command = "fish";
        General.Name = "fish";
      };
    };

    configFile = {
      konsolerc."Desktop Entry".DefaultProfile = "fish.profile";

      katerc."KTextEditor Document"."Auto Save" = true;
      katerc."KTextEditor Document"."Auto Save On Focus Out" = true;
    };
  };
}
