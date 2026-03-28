{
  self,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.containers.pocket-id
    self.nixosModules.services.snell
  ];

  programs.nix-ld.enable = true;
  # Hacky way to meet prerequisites(https://code.visualstudio.com/docs/remote/linux) make vscode happy, so it can proceed to install bin under ~/.vscode-server
  # mkdir /usr/lib64/ && ln -s /run/current-system/sw/share/nix-ld/lib/libstdc++.so.6 /usr/lib64/libstdc++.so.6


  # services.sing-box.enable = true;
  # services.sing-box.settings = {
  #   log.level = "info";
  #   inbounds = [
  #     {
  #       type = "anytls";
  #       tag = "anytls-in";
  #       listen = "0.0.0.0";
  #       listen_port = 8888;
  #       users = [
  #         {
  #           password = {
  #             _secret = "/secret/proxy-pwd";
  #           };
  #         }
  #       ];
  #       tls = {
  #         enabled = true;
  #         insecure = true;
  #       };
  #     }
  #   ];
  # };

}
