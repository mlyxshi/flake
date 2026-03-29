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

  # let pre-builded binary run without patchelf
  programs.nix-ld.enable = true;

  # Hacky way to meet prerequisites(https://code.visualstudio.com/docs/remote/linux) make vscode happy, so it can proceed to install bin under ~/.vscode-server
  
  # The process of vscode remote server setup
  # 1. install statically linked binary named like "code-cfbea10c5ffb233ea9177d34726e6056e89913dc" to ~/.vscode-server
  # 2. code-cfbea10c5ffb233ea9177d34726e6056e89913dc check if /usr/lib64/libstdc++.so.6 is existed
      # NO, error  "can not find libstdc++.so or ldconfig for GNU environments"
      # Yes, continue to download other parts and binary of vscode server to ~/.vscode-server

  systemd.tmpfiles.settings."10-vscode-remote-ssh-workaround" = {
    "/usr/lib64/".d = {};
    "/usr/lib64/libstdc++.so.6"."L+" = {
      argument = "${lib.getLib pkgs.stdenv.cc.cc}/lib/libstdc++.so.6";
    };
  };

}
