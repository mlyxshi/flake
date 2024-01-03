{ self, nixpkgs, sops-nix, home-manager, xremap }:

nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    home-manager.nixosModules.default
    self.nixosModules.os.nixos.desktop
    self.nixosModules.network
    self.nixosModules.fileSystem.ext4
    self.nixosModules.services.ssh-config
    ./hardware.nix
    ./misc.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "utm";
      services.getty.autologinUser = "root";

      hardware.uinput.enable = true;
      users.groups.uinput.members = [ "dominic" ];
      users.groups.input.members = [ "dominic" ];

      home-manager.users.root = import ../../home;
      home-manager.users.dominic = {
        imports = [
          ../../home/desktop.nix
          xremap.homeManagerModules.default
        ];
        services.xremap = {
          withKDE = true;
          config = {
            # modmap = [
            #   {
            #     name = "Global";
            #     remap = { 
            #        = "";
            #     }; # globally remap CapsLock to Esc
            #   }
            # ];
            # other xremap settings go here

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
            ];
          };
        };

      };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
    }
  ];
  specialArgs = { inherit self nixpkgs; };
}
