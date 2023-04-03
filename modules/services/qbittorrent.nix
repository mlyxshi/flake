#  Run external program on torrent completion
# /run/current-system/sw/bin/qbScript "%N" "%F" "%C" "%Z" "%I" "%L"
# change password
# disable Cross-Site Request Forgery (CSRF) protection
{ pkgs, lib, config, ... }:
let
  qbScript = pkgs.writeShellApplication {
    name = "qbScript";
    runtimeInputs = with pkgs; [ rclone curl xh ];
    checkPhase = ""; #dummy checkPhase to bypass strict shellcheck
    text = ''
      torrent_name=$1
      content_path=$2
      files_num=$3
      torrent_size=$4
      file_hash=$5
      category=$6
      rclone_dest="gdrive:bangumi"

      echo "Torrent Name：$torrent_name" 
      echo "Content Path：$content_path" 
      echo "File Number：$files_num" 
      echo "Size：$(($torrent_size/1024/1024)) MB"
      echo "HASH: $file_hash"

      if [ -f "$content_path" ]
      then
        rclone  -v copy  "$content_path" $rclone_dest
      elif [ -d "$content_path" ]
      then
        rclone  -v copy --transfers 32 "$content_path" $rclone_dest/"$torrent_name"
      fi

      # For any defined category, after download, upload to googledrive but do not auto delete(important resource, PT share ratio requirement)
      [[ -n "$category" ]] || curl -X POST "http://127.0.0.1:8080/api/v2/torrents/delete" -d hashes=$file_hash -d deleteFiles=true

      xh --ignore-stdin https://api.day.app/push device_key=$BARK_KEY title=Upload icon=https://drive.google.com/favicon.ico body="$torrent_name"
      echo "-------------------------------------------------------------------------------------"
    '';

  };
in
{
  age.secrets.rclone-env.file = ../../secrets/rclone-env.age;
  age.secrets.bark-ios.file = ../../secrets/bark-ios.age;

  users = {
    users.qbittorrent = {
      group = "qbittorrent";
      isSystemUser = true;
    };
    groups.qbittorrent = { };
  };

  environment.systemPackages = with pkgs; [
    qbittorrent-nox
    rclone
    qbScript
  ];

  # https://github.com/1sixth/flakes/blob/master/modules/qbittorrent-nox.nix
  # https://github.com/qbittorrent/qBittorrent/wiki/How-to-use-portable-mode

  systemd.services.qbittorrent-nox = {
    after = [ "local-fs.target" "network-online.target" ];
    serviceConfig = {
      User = "qbittorrent";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --profile=%S/qbittorrent-nox --relative-fastresume";
      StateDirectory = "qbittorrent-nox";
      EnvironmentFile = [
        config.age.secrets.rclone-env.path
        config.age.secrets.bark-ios.path
      ];
      PrivateTmp = true;
    };
    wantedBy = [ "multi-user.target" ];
  };


  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.qbittorrent-nox = {
          rule = "Host(`qb.${config.networking.domain}`)";
          entryPoints = [ "web" ];
          service = "qbittorrent-nox";
        };

        services.qbittorrent-nox.loadBalancer.servers = [{
          url = "http://127.0.0.1:8080";
        }];
      };
    };
  };

  system.activationScripts.cloudflare-dns-sync-qbittorrent-nox = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync qb.${config.networking.domain}";
  };
}
