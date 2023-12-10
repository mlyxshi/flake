{ pkgs, ... }: {
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    taps = [
      "homebrew/cask-fonts"
      "homebrew/cask-drivers" # yubikey
      "homebrew/cask-versions" # beta
      "majd/repo"
    ];

    brews = [
      "rclone"
      "nodejs"
      "aria2"
      "protobuf"
      "neofetch"
      "iproute2mac"
      "mas"
      "qemu"
      "imagemagick" #kitty image dependency
      "smartmontools"
      "cloudflared"
    ];

    casks = [
      "ubiquiti-unifi-controller"
      "betterdisplay"
      "mpv"
      "proxyman"
      "sloth"
      "yubico-yubikey-manager"
      "android-platform-tools"
      "element"
      "input-source-pro"
      "kitty"
      "macfuse" # rclone mount
      "utm-beta"
      "font-roboto-mono-nerd-font"
      "calibre"
      "ipatool"
      "maczip"
      "openineditor-lite"
      "openinterminal-lite"
      "provisionql"
      "wireshark"
      "raycast"
      "visual-studio-code"
      "transmission"
      "google-drive"
      "istat-menus"
      "neteasemusic"
      "telegram-desktop"

      # Already installed from offical website <-- Uncomment this when completely reinstall macos
      # "surge"
      # "firefox"

      # "google-chrome"
      # "airbuddy"
      # "bartender"
      # "deepl"
      # "imazing"
      # "uninstallpkg"
      # "suspicious-package"

      # "snipaste"
    ];

    # Only for fresh installation
    # masApps = {
    #   AdGuard = 1440147259;

    #   WeChat = 836500024;

    #   Things = 904280696;
    #   GoodNotes = 1444383602;
    #   Cleaner-for-Xcode = 1296084683;
    #   Amphetamine = 937984704;

    #   Screens = 1224268771;
    #   Microsoft-Remote-Desktop = 1295203466;

    #   Pasty = 1544620654;
    #   Bob = 1630034110;
    #   Xcode = 497799835;
    #   Bitwarden = 1352778147;
    #   Infuse = 1136220934;
    #   LyricsX = 1254743014;
    #   Apple-Configurator = 1037126344;
    # };
  };
}
# Other Application not in Homebrew/Nixpkgs/Appstore
# Install Manually
# Hopper-Disassembler https://www.hopperapp.com/

