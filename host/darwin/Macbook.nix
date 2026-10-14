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

  # environment.systemPackages = with pkgs; [
  # ];

  homebrew = {

    brews = [
      "cloudflared"
      "oci-cli"
      "ipatool"
    ];

    casks = [

    ];
  };

}
