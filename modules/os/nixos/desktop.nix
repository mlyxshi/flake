{ pkgs, lib, config, self, ... }: {

  imports = [ self.nixosModules.os.nixos.base ];

  users.users.dominic = {
    isNormalUser = true;
    description = "mlyxshi";
    shell = pkgs.fish;
    hashedPassword =
      "$6$fwJZwHNLE640VkQd$SrYMjayP9fofIncuz3ehVLpfwGlpUj0NFZSssSy8GcIXIbDKI4JnrgfMZxSw5vxPkXkAEL/ktm3UZOyPMzA.p0";
    extraGroups = [ "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;

  environment.etc."firefox/policies/policies.json".text =
    builtins.toJSON (import ../../../home/firefox/policy.nix);

  # time.timeZone = "Asia/Tokyo";

  environment.systemPackages = with pkgs; [ 
    kdePackages.krfb # kde vnc server
  ];

  fonts = {
    packages = [
      (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; }) # Terminal Font
      pkgs.SF-Pro # English
      pkgs.PingFang # Chinese/Japanese
    ];
    enableDefaultPackages =
      false; # If Sway is enabled, enableDefaultPackages is true by default <-- I don't need extra default fonts
    # fc-list
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "RobotoMono Nerd Font" ];
        sansSerif = [ "SF Pro" ];
        serif = [ "SF Pro" ];
      };
    };
  };


  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;


  services.flatpak.enable = true;

  # networking.networkmanager.enable = true;
}
