{ xremap,... }: {

  imports = [
    xremap.homeManagerModules.default
  ];

  services.xremap = {
    withKDE = true;
    config = {
      # globally remap
      # modmap = [
      #   {
      #     name = "Global";
      #     remap = { 
      #        = "";
      #     };
      #   }
      # ];

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
          };
          application.only = [
            "firefox"
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
          };
          application.only = [
            "konsole"
          ];
        }

        {
          name = "appswitcher";
          remap = {
            SUPER-TAB = "ALT-TAB";
          };
        }
      ];
    };
  };
}