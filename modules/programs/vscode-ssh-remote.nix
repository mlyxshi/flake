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

  # let pre-builded binary run
  programs.nix-ld.enable = true;

  # Hacky way to meet prerequisites(https://code.visualstudio.com/docs/remote/linux) make vscode happy, so it can proceed to install bin under ~/.vscode-server
  systemd.tmpfiles.settings."10-vscode-remote-ssh-workaround" = {
    "/usr/lib64/".d = {
    };

    "/usr/lib64/libstdc++.so.6"."L+" = {
      argument = "${lib.getLib pkgs.stdenv.cc.cc}/lib/libstdc++.so.6";
    };
  };

}
