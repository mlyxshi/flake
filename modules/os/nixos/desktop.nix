{ pkgs, lib, config, self, ... }: {

  imports = [
    self.nixosModules.os.nixos.base
  ];

  users.users.dominic = {
    isNormalUser = true;
    description = "mlyxshi";
    shell = pkgs.fish;
    hashedPassword = "$6$fwJZwHNLE640VkQd$SrYMjayP9fofIncuz3ehVLpfwGlpUj0NFZSssSy8GcIXIbDKI4JnrgfMZxSw5vxPkXkAEL/ktm3UZOyPMzA.p0";
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    firefox
    home-manager
  ];

  environment.etc."firefox/policies/policies.json".text = builtins.toJSON (import ../../../home/firefox/policy.nix);

  fonts = {
    packages = [
      (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; }) # Terminal Font
      pkgs.SF-Pro # English
      pkgs.PingFang # Chinese/Japanese
    ];
    enableDefaultPackages = false; # If Sway is enabled, enableDefaultPackages is true by default <-- I don't need extra default fonts
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

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;

}
