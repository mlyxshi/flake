{
  pkgs,
  lib,
  ...
}:
{
  # vscode extension Nix IDE needs
  environment.systemPackages = with pkgs; [
    nixfmt
    nixd
  ];

  # run pre-built binaries without patchelf
  programs.nix-ld.enable = true;

  # In your desktop Vscode settings

  # Download code-server in local then scp to remote
  # "remote.SSH.localServerDownload": "always",

  # if default shell is fish
  # "remote.SSH.remotePlatform": {
  #     "jp2": "linux",
  #     "jp1": "linux",
  #     "us": "linux"
  # },

}
