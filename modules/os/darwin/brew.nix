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
      "openjdk"
      ##############################################
      # "payload-dumper-go"
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
      "input-source-pro"
      "utm"
      "crystalfetch"
      "font-roboto-mono-nerd-font"
      "calibre"
      "maczip"
      "openineditor-lite"
      "openinterminal-lite"
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

      "uninstallpkg"
      # "suspicious-package"

      # "snipaste"

      ##############################################
      # "karabiner-elements"
      # "wireshark"
    ];

    # Only for fresh installation
    # masApps = {

    #   Immersive-Translate = 6447957425;
    #   uBlacklist = 1547912640; 
    #   SponsorBlock = 1573461917;
    #   Userscripts = 1463298887;
    #   AdGuard = 1440147259;

    #   WeChat = 836500024;

    #   AmorphousDiskMark = 1168254295;
    #   WiFi-Explorer = 494803304;

    #   Microsoft-Remote-Desktop = 1295203466;

    #   Pasty = 1544620654;
    #   Bob = 1630034110;
    #   Xcode = 497799835;
    #   Infuse = 1136220934;
    #   Apple-Configurator = 1037126344;
    # };
  };
}