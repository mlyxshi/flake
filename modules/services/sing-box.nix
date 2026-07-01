{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.sing-box-server;
  settingsFormat = pkgs.formats.json { };
in
{

  options = {
    services.sing-box-server = {

      package = lib.mkPackageOption pkgs "sing-box" { };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };
        default = { };
      };

      warp = {
        enable = lib.mkEnableOption "warp";
      };

      tor = {
        enable = lib.mkEnableOption "tor";
      };

      i2p = {
        enable = lib.mkEnableOption "i2p";
      };
    };
  };

  config = lib.mkMerge [
    {
      services.sing-box-server.settings = {
        log.level = "info";
        inbounds = [
          {
            type = "anytls";
            tag = "anytls-in";
            listen = "0.0.0.0";
            listen_port = 8889;
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
        outbounds = [
          {
            type = "direct";
            tag = "direct";
          }
        ]
        ++ lib.optional cfg.warp.enable {
          type = "socks";
          tag = "warp";
          server = "127.0.0.1";
          server_port = 40000;
          version = "5";
        }
        ++ lib.optional cfg.tor.enable {
          type = "socks";
          tag = "tor";
          server = "127.0.0.1";
          server_port = 9150;
          version = "5";
        }
        ++ lib.optional cfg.i2p.enable {
          type = "socks";
          tag = "i2p";
          server = "127.0.0.1";
          server_port = 4447;
          version = "5";
        };
        route = {
          rules = [
            {
              action = "route";
              domain_suffix = [ ".onion" ];
              outbound = "tor";
            }
            {
              action = "route";
              domain_suffix = [ ".i2p" ];
              outbound = "i2p";
            }
          ];
          final = if cfg.warp.enable then "warp" else "direct";
        };
      };

      systemd.services.sing-box = {
        serviceConfig = {
          User = "sing-box";
          Group = "sing-box";
          StateDirectory = "sing-box";
          StateDirectoryMode = "0700";
          RuntimeDirectory = "sing-box";
          RuntimeDirectoryMode = "0700";
          WorkingDirectory = "/var/lib/sing-box";
          ExecStartPre =
            let
              script = pkgs.writeShellScript "sing-box-pre-start" ''
                ${utils.genJqSecretsReplacementSnippet cfg.settings "/run/sing-box/config.json"}
                chown --reference=/run/sing-box /run/sing-box/config.json
              '';
            in
            "+${script}";
          ExecStart = [
            ""
            "${lib.getExe cfg.package} -D \${STATE_DIRECTORY} -C \${RUNTIME_DIRECTORY} run"
          ];
        };
        # After= is specified by upstream
        requires = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
      };

      users = {
        users.sing-box = {
          isSystemUser = true;
          group = "sing-box";
        };
        groups.sing-box = { };
      };
    }

    (lib.mkIf cfg.i2p.enable {
      services.i2pd = {
        enable = true;
        address = "127.0.0.1";
        proto = {
          socksProxy.enable = true;
        };
      };
    })

  ];

}
