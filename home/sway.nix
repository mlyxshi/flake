{ pkgs, ... }: {
  imports = [
    ./default.nix
    ./firefox
  ];

  xdg.configFile."sway/config".source = ../config/sway/config;

  home.packages = with pkgs; [
    swaylock
    swayidle
    wl-clipboard
    pavucontrol
    baobab
    fuzzel

    xorg.xlsclients #xorg.xmodmap
    wev

    kitty
  ];

  # Fix Strange Cursor Size Under Sway
  home.pointerCursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    gtk.enable = true;
  };

  # Firefox can use dark theme toolbar
  gtk = {
    enable = true;
    theme = {
      package = pkgs.materia-theme;
      name = "Materia";
    };
    iconTheme = {
      package = pkgs.numix-icon-theme-circle;
      name = "Numix-Circle";
    };
  };
}
