{ self, pkgs, lib, config, home-manager, ... }: {

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
      enable = lib.mkForce true;
      defaultFonts = {
        monospace = [ "RobotoMono Nerd Font" ];
        sansSerif = [ "SF Pro" ];
        serif = [ "SF Pro" ];
      };
    };
  };

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  home-manager.users.dominic = import ../../../home/desktop.nix;
}
