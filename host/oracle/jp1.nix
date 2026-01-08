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
    self.nixosModules.containers.commit-notifier
    # self.nixosModules.services.snell
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
  #             _secret = "/secret/ss-password-2022";
  #           };
  #         }
  #       ];
  #       tls = {
  #         enabled = true;
  #         certificate_path = "/root/certificate";
  #         key_path = "/root/key";
  #       };
  #     }
  #   ];
  # };

}
