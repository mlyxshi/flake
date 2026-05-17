{
  self,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    self.nixosModules.programs.vscode-ssh-remote

    self.nixosModules.services.transmission
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";
    inbounds = [
      {
        type = "anytls";
        tag = "anytls-in";
        listen = "0.0.0.0";
        listen_port = 8888;
        users = [
          {
            password = {
              _secret = "/secret/proxy-pwd";
            };
          }
        ];
        tls = {
          enabled = true;
          insecure = true;
        };
      }
    ];
  };

  

}
