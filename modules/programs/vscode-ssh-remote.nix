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

  # The process of vscode remote server setup
  # See more details: nix build nixpkgs#vscode-extensions.ms-vscode-remote.remote-ssh         
  # share/vscode/extensions/ms-vscode-remote.remote-ssh/out/install-script/scripts/linux-exec-server-installer.sh

  # 1. install Visual Studio Code CLI Standalone which is a statically linked binary named like "code-cfbea10c5ffb233ea9177d34726e6056e89913dc" to ~/.vscode-server
  # 2. ~/.vscode-server/code-cfbea10c5ffb233ea9177d34726e6056e89913dc status
  # [2026-03-29 06:38:26] error This machine does not meet Visual Studio Code Server's prerequisites, expected either...
  #   - find libstdc++.so or ldconfig for GNU environments
  #   - find /lib/ld-musl-aarch64.so.1, which is required to run the Visual Studio Code Server in musl environments

  # So we need to make Visual Studio Code CLI Standalone happy, then it can continue install code-server bin to ~/.vscode-server/cli/servers

  systemd.tmpfiles.settings."10-vscode-remote-ssh-workaround" = {
    "/usr/lib64/".d = {};
    "/usr/lib64/libstdc++.so.6"."L+" = {
      argument = "${lib.getLib pkgs.stdenv.cc.cc}/lib/libstdc++.so.6";
    };
  };

}
