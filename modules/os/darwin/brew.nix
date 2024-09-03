{ pkgs, ... }: {
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    taps = [
      "homebrew/services"
      "homebrew/cask-fonts"
      "homebrew/cask-drivers" # yubikey
      "homebrew/cask-versions" # beta
    ];

    brews = [
      "ipfs"
      "rclone"
      "nodejs"
      "aria2"
      "protobuf"
      "iproute2mac"
      "mas"
      "qemu"
      "smartmontools"
      "cloudflared"
      "yt-dlp"
      "ffmpeg"
      "mediainfo"
      "payload-dumper-go"
      "openjdk"
      # "deno"
    ];

    casks = [
      "orbstack"
      "jordanbaird-ice"
      "vnc-viewer"
      "ubiquiti-unifi-controller"
      "betterdisplay"
      "stolendata-mpv"
      "proxyman"
      "sloth"
      "yubico-yubikey-manager"
      "android-platform-tools"
      "element"
      # "karabiner-elements"
      "input-source-pro"
      "macfuse" # rclone mount
      "utm"
      "font-roboto-mono-nerd-font"
      "calibre"
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

    #   GoodNotes = 1444383602;
    #   Cleaner-for-Xcode = 1296084683;
    #   Amphetamine = 937984704;

    #   Microsoft-Remote-Desktop = 1295203466;

    #   Pasty = 1544620654;
    #   Bob = 1630034110;
    #   Xcode = 497799835;
    #   Infuse = 1136220934;
    #   Apple-Configurator = 1037126344;
    # };
  };
}
# Other Application not in Homebrew/Nixpkgs/Appstore
# Install Manually
# Hopper-Disassembler https://www.hopperapp.com/
