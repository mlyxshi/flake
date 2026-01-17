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
