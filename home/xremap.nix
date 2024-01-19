{ pkgs, lib, ... }:
let
  config = {
    keymap = [
      {
        name = "edit";
        remap = {
          SUPER-z = "CTRL-z";
          SUPER-x = "CTRL-x";
          SUPER-c = "CTRL-c";
          SUPER-v = "CTRL-v";
          SUPER-a = "CTRL-a";
          SUPER-s = "CTRL-s";
          SUPER-t = "CTRL-t";
          SUPER-f = "CTRL-f";
          SUPER-MINUS = "CTRL-MINUS";
          SUPER-EQUAL = "CTRL-EQUAL";
          SUPER-q = "CTRL-q";
          SUPER-w = "CTRL-w";
        };
        application.only = [
          "firefox"
          "kate"
          "code"
        ];
      }

      {
        name = "konsole";
        remap = {
          SUPER-c = "CTRL-SHIFT-c";
          SUPER-v = "CTRL-SHIFT-v";
          SUPER-t = "CTRL-SHIFT-t";
          SUPER-f = "CTRL-SHIFT-f";
          SUPER-q = "CTRL-SHIFT-q";
          SUPER-w = "CTRL-SHIFT-w";
        };
        application.only = [
          "konsole"
        ];
      }
    ];
  };

  configFile = pkgs.writeTextFile {
    name = "xremap-config.yml";
    text =
      lib.generators.toYAML { } config;
  };
in
{
  systemd.user.services.xremap = {
    Unit = {
      Description = "xremap service";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.xremap}/bin/xremap ${configFile}";
      Restart = "always";
      # Environment =  "RUST_LOG=debug";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

}
