{ pkgs, lib, config, ... }: {

  imports = [
    ./default.nix
  ];

  networking.hostName = "Macbook";

  homebrew = {

    taps = [
      "lihaoyun6/tap"
    ];

    brews = [
      "cloudflared"
    ];

    casks = [
      "vnc-viewer"
      "snipaste"

      "neteasemusic"
      "iina"
      "element"
      "telegram-desktop"

      "topit"
    ];
  };

}