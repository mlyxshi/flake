{ pkgs, lib, config, ... }:
let
  # send notification to bark(iOS)
  # disable CSRF Protection
  pre-config = pkgs.writeText "pre-config" ''
    [AutoRun]
    enabled=true
    program=/run/current-system/sw/bin/deno run --allow-net --allow-env /etc/qbScript \"%N\" \"%F\" \"%C\" \"%Z\" \"%I\" \"%L\"
    
    [BitTorrent]
    Session\DefaultSavePath=/var/lib/media
    Session\GlobalMaxRatio=0
    Session\MaxRatioAction=1

    [Preferences]
    WebUI\CSRFProtection=false
  '';
in
{
  age.secrets.bark-ios.file = ../../../secrets/bark-ios.age;

  users = {
    users.qbittorrent = {
      group = "qbittorrent";
      isNormalUser = true;
      uid = 1000;
    };
    groups.qbittorrent = {
      gid = 1000;
    };
  };

  environment.systemPackages = with pkgs; [
    deno
  ];

  environment.etc."qbScript".source = ./main.ts;

  # https://github.com/qbittorrent/qBittorrent/wiki/How-to-use-portable-mode
  systemd.services.qbittorrent-nox = {
    after = [ "local-fs.target" "network-online.target" ];
    environment = {
      DENO_DIR = "%S/qbittorrent-nox/.deno";
    };
    serviceConfig = {
      User = "qbittorrent";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --profile=%S/qbittorrent-nox --relative-fastresume";
      StateDirectory = "qbittorrent-nox";
      EnvironmentFile = [
        config.age.secrets.bark-ios.path
      ];
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.qbittorrent-nox-config-init = {
    before = [ "qbittorrent-nox.service" ];
    unitConfig.ConditionPathExists = "!%S/qbittorrent-nox/qBittorrent/config/qBittorrent.conf";
    serviceConfig.User = "qbittorrent";
    serviceConfig.StateDirectory = "qbittorrent-nox";
    script = ''
      mkdir -p /var/lib/qbittorrent-nox/qBittorrent/config
      cat ${pre-config} > /var/lib/qbittorrent-nox/qBittorrent/config/qBittorrent.conf
    '';
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.media-init = {
    before = [ "qbittorrent-nox.service" ];
    serviceConfig.User = "qbittorrent";
    serviceConfig.StateDirectory = "media";
    script = ''
      mkdir -p /var/lib/media
    '';
    wantedBy = [ "multi-user.target" ];
  };
}
