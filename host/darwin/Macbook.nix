{
  pkgs,
  lib,
  config,
  ...
}:
{

  imports = [
    ./default.nix
  ];

  networking.hostName = "Macbook";

  environment.systemPackages = with pkgs; [
    sing-box
  ];

  homebrew = {

    brews = [
      "cloudflared"
      "oci-cli"
      "ipatool"
      # "flyctl"
    ];

    casks = [
      "vnc-viewer"
      "snipaste"

      "neteasemusic"
      "iina"
      "element"
      "telegram-desktop"

      "monitorcontrol"

      "impactor"
    ];
  };

}
