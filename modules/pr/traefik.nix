# https://github.com/NixOS/nixpkgs/pull/490985
# remove when pr merge
{
  options,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.types)
    attrsOf
    bool
    listOf
    nullOr
    path
    str
    submodule
    package
    ;
  inherit (lib)
    concatMapStringsSep
    concatStringsSep
    filter
    getExe
    literalExpression
    maintainers
    mapAttrs'
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    mkRenamedOptionModule
    nameValuePair
    optional
    optionalAttrs
    remove
    id
    ;

  cfg = config.services.traefik;
  opt = options.services.traefik;

  # JSON is considered valid YAML by Traefik.
  format = pkgs.formats.json { };

  staticFile =
    if cfg.static.file == null then
      format.generate "static_config.json" cfg.static.settings
    else
      cfg.static.file;
in
{
    
  options.services.traefik = {
    enable = mkEnableOption "Traefik web server";
    package = mkPackageOption pkgs "traefik" { };

    static = {
      file = mkOption {
        default = null;
        example = literalExpression "/path/to/static_config.toml";
        type = nullOr path;
        description = ''
          Path to Traefik's static configuration file.

          ::: {.note}
          Using this option has precedence over {option}`services.traefik.static.settings`.
          :::
        '';
      };
      settings = mkOption {
        type = format.type;
        default = {
          entryPoints.http.address = ":80";
        };
      };
    };

    dynamic = {
      file = mkOption {
        default = null;
        example = literalExpression "/path/to/dynamic_config.toml";
        type = nullOr path;
        description = ''
          Path to Traefik's dynamic configuration file.

          ::: {.note}
          You cannot use this option alongside the declarative configuration options.
          :::
        '';
      };
      dir = mkOption {
        default = if cfg.dynamic.file == opt.dynamic.file.default then "/var/lib/traefik/dynamic" else null;
        defaultText = literalExpression "if cfg.dynamic.file == opt.dynamic.file.default then '/var/lib/traefik/dynamic' else null";
        example = literalExpression "/etc/traefik/";
        type = nullOr path;
        description = ''
          Path to the directory Traefik should watch for configuration files.

          ::: {.warning}
          Files in this directory matching the glob `_nixos-*` (reserved for Nix-managed dynamic configurations) will be deleted as part of
          `systemd-tmpfiles-resetup.service`, _**regardless of their origin.**_.
          :::
        '';
      };
      files = mkOption {
        type = attrsOf (submodule {
          options.settings = mkOption {
            type = format.type;
            description = ''
              Dynamic configuration for Traefik, written in Nix.

              ::: {.note}
              This will be serialized to JSON (which is considered valid YAML) at build, and passed as part of the static file.
              :::
            '';
            example = {
              http.routers."api" = {
                service = "api@internal";
                rule = "Host(`localhost`)";
              };
            };
          };
        });
        default = { };
        example = {
          "dashboard".settings = {
            http.routers."api" = {
              service = "api@internal";
              rule = "Host(`198.51.100.1`)";
            };
          };
        };
        description = ''
          Dynamic configuration files to write. These are symlinked in `services.traefik.dynamic.dir` upon activation,
          allowing configuration to be upated without restarting the primary daemon.

          ::: {.note}
          Due to [a limitation in Traefik](https://github.com/traefik/traefik/issues/10890); any syntax error in a dynamic configuration will cause the _**entire file provider**_ to be ignored.
          This may cause interuption in service, which may include access to the Traefik dashboard, if [enabled and configured](https://doc.traefik.io/traefik/operations/dashboard).
          :::
        '';
      };
      # TODO: Drop in 26.11.
      settings = mkOption {
        type = format.type;
        description = ''
          Dynamic configuration for Traefik, written in Nix.
          This option is intended for easily migrating pre-26.05 Traefik configurations, and will be removed in NixOS 26.11.

          ::: {.note}
          Configurations added here will be translated into a file for {option}`services.traefik.dynamic.files`, named `custom-migrated`.
          :::
        '';
        default = { };
        example = {
          http.routers."api" = {
            service = "api@internal";
            rule = "Host(`localhost`)";
          };
        };
      };
    };
    localPlugins = mkOption {
      default = [ ];
      type = listOf package;
      example = literalExpression "[ pkgs.fosrl-badger pkgs.geoblock ]";
      description = ''
        List of local plugins to be added to the `localPlugins` attribute in the static configuration. These plugins are usually packaged in Nixpkgs, and are managed by Nix.
      '';
    };

    dataDir = mkOption {
      default = "/var/lib/traefik";
      type = path;
      description = ''
        Location for any persistent data Traefik creates, such as the ACME certificate store.

        ::: {.note}
        If left as the default value, this directory will automatically be created
        before the Traefik server starts, otherwise you are responsible for ensuring
        the directory exists with appropriate ownership and permissions.
        :::
      '';
    };

    user = mkOption {
      default = "traefik";
      example = "docker";
      type = str;
      description = ''
        User under which Traefik runs.

        ::: {.note}
        If left as the default value this user will automatically be created
        on system activation, otherwise you are responsible for
        ensuring the user exists before the Traefik service starts.
        :::
      '';
    };

    group = mkOption {
      default = "traefik";
      type = str;
      description = ''
        Primary group under which Traefik runs.
        For the Docker backend, use {option}`services.traefik.supplementaryGroups` instead of overriding this option.

        ::: {.note}
        If left as the default value this group will automatically be created
        on system activation, otherwise you are responsible for
        ensuring the group exists before the Traefik service starts.
        :::
      '';
    };

    supplementaryGroups = mkOption {
      default = [ ];
      type = listOf str;
      example = [ "docker" ];
      description = ''
        Additional groups under which Traefik runs.
        This can be used to give additional permissions, such as the group required by the `docker` provider.

        ::: {.note}
        With the `docker` provider, Traefik manages connection to containers via the Docker socket,
        which requires membership of the `docker` group for write access.
        :::
      '';
    };

    environmentFiles = mkOption {
      default = [ ];
      type = listOf path;
      example = [ "/run/secrets/traefik.env" ];
      description = ''
        Files to load as an environment file just before Traefik starts.
        This can be used to pass secrets such as [DNS challenge API tokens](https://doc.traefik.io/traefik/https/acme/#providers) or [EAB credentials](https://doc.traefik.io/traefik/reference/static-configuration/env/).
        ```
        DESEC_TOKEN=
        TRAEFIK_CERTIFICATESRESOLVERS_<NAME>_ACME_EAB_HMACENCODED=
        TRAEFIK_CERTIFICATESRESOLVERS_<NAME>_ACME_EAB_KID=
        ```
        ::: {.warn}
        The traefik static configuration methods (env, CLI, and file) are mutually exclusive.
        :::
        ```
      '';
    };
  };

  config = mkIf cfg.enable {
 
    # https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
    boot.kernel.sysctl = {
      "net.core.rmem_max" = 2500000;
      "net.core.wmem_max" = 2500000;
    };

    # If a dynamic file or directory has been set, add it as a provider in the static configuration
    services.traefik = mkIf (cfg.static.file == opt.static.file.default) {
      dynamic.files = mkIf (cfg.dynamic.settings != opt.dynamic.settings.default) {
        "custom-migrated".settings = cfg.dynamic.settings;
      };
      static.settings = mkMerge [

        (mkIf (cfg.localPlugins != [ ]) {
          experimental.localPlugins = lib.listToAttrs (
            map (plugin: lib.nameValuePair plugin.plugin { inherit (plugin) moduleName; }) cfg.localPlugins
          );
        })

        (mkIf (cfg.dynamic.dir != null || cfg.dynamic.file != opt.dynamic.file.default) {
          providers.file = {
            directory = mkIf (cfg.dynamic.dir != null) cfg.dynamic.dir;
            filename = mkIf (cfg.dynamic.file != opt.dynamic.file.default) cfg.dynamic.file;
            watch = mkDefault true;
          };
        })
      ];
    };

    systemd.services.traefik = {
      description = "Traefik reverse proxy";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      startLimitIntervalSec = 86400;
      startLimitBurst = 5;
      unitConfig.Documentation = "https://doc.traefik.io/traefik/";
      serviceConfig = {
        EnvironmentFile = cfg.environmentFiles;
        ExecStartPre = mkIf (cfg.localPlugins != [ ]) (
          pkgs.writeShellScript "traefik-pre-start-ln-plugins" ''
            ${lib.getExe' pkgs.coreutils "ln"} -Tsf ${
              toString (
                pkgs.symlinkJoin {
                  name = "traefik-plugins";
                  paths = cfg.localPlugins;
                }
              )
            } plugins-local
          ''
        );
        ExecStart = "${getExe cfg.package} --configfile=${staticFile}";
        Type = "notify";
        User = cfg.user;
        Group = cfg.group;
        SupplementaryGroups = mkIf (cfg.supplementaryGroups != [ ]) cfg.supplementaryGroups;
        Restart = "always";
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        NoNewPrivileges = true;
        TasksMax = 64;
        LimitNOFILE = 1048576;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ReadWritePaths = [ cfg.dataDir ];
        ReadOnlyPaths = optional (cfg.dynamic.dir != null) cfg.dynamic.dir;
        RuntimeDirectoryMode = "0700";
        RuntimeDirectory = "traefik";
        WorkingDirectory = cfg.dataDir;
        WatchdogSec = "1s";
      };
    };

    systemd.tmpfiles.settings."10-traefik" = mkMerge [
      (mkIf (cfg.user == "traefik") {
        ${cfg.dataDir}.d = {
          inherit (cfg) user group;
          mode = "0700";
        };
      })
      (mkIf (cfg.dynamic.dir != null) (
        {
          ${cfg.dynamic.dir}.d = {
            inherit (cfg) user group;
            mode = "0700";
          };
          "${cfg.dynamic.dir}/_nixos-*".r = { };
        }
        // (mapAttrs' (
          name: value:
          nameValuePair "${cfg.dynamic.dir}/_nixos-${name}.yml" {
            "L+" = {
              mode = "0444";
              argument = toString (format.generate name value.settings);
            };
          }
        ) cfg.dynamic.files)
      ))
    ];

    users = {
      users = optionalAttrs (cfg.user == "traefik") {
        traefik = {
          inherit (cfg) group;
          isSystemUser = true;
        };
      };
      groups = optionalAttrs (cfg.group == "traefik") { traefik = { }; };
    };
  };

}
