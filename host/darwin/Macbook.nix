{ pkgs, lib, config, ... }: {

  imports = [
    ./default.nix
  ];

  networking.hostName = "Macbook";

  nix.enable = false; # DeterminateSystems  Nix

  environment.systemPackages = with pkgs; [
    sing-box
  ];

  homebrew = {

    brews = [
      "cloudflared"
      "ipatool"
    ];

    casks = [
      "vnc-viewer"
      "snipaste"

      "neteasemusic"
      "iina"
      "element"
      "telegram-desktop"

      "monitorcontrol"
    ];
  };

}
