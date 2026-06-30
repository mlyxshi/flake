{
  self,
  config,
  pkgs,
  lib,
  ...
}:
let
  old-pkgs = import (builtins.fetchGit {
    name = "my-old-revision";
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "refs/heads/nixpkgs-unstable";
    rev = "e6f23dc08d3624daab7094b701aa3954923c6bbb";
  }) { };

  sing-box-stable = old-pkgs.sing-box;
in
{

  imports = [
    self.nixosModules.programs.vscode-ssh-remote
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  services.sing-box.package = sing-box-stable;
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
