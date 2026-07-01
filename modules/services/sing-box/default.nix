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

  imports = [
    ./i2p.nix
    ./tor.nix
    ./warp.nix
  ];

  options = {
    services.sing-box-server = {

      package = lib.mkPackageOption pkgs "sing-box" { };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };
        default = { };
      };

    };
  };

  config = {

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
      ];

      route = {
        rules = [ ];
        final = "direct";
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
  };

}
