{ config, pkgs, lib, ... }:
let
  # https://github.com/zedeus/nitter/blob/master/nitter.example.conf
  NitterConfig = pkgs.writeText "NitterConfig" ''
    [Server]
    address = "0.0.0.0"
    port = 8080
    https = false  # disable to enable cookies when not using https
    httpMaxConnections = 100
    staticDir = "./public"
    title = "nitter"
    hostname = "twitter.mlyxshi.com"
    [Cache]
    listMinutes = 240  # how long to cache list info (not the tweets, so keep it high)
    rssMinutes = 10  # how long to cache rss queries
    redisHost = nitter-db  # Change to "nitter-redis" if using docker-compose
    redisPort = 6379
    redisPassword = ""
    redisConnections = 20  # connection pool size
    redisMaxConnections = 30
    # max, new connections are opened when none are available, but if the pool size
    # goes above this, they're closed when released. don't worry about this unless
    # you receive tons of requests per second
    [Config]
    hmacKey = "secretkey"  # random key for cryptographic signing of video urls
    base64Media = false  # use base64 encoding for proxied media urls
    enableRSS = true  # set this to false to disable RSS feeds
    enableDebug = false  # enable request logs and debug endpoints
    proxy = ""  # http/https url, SOCKS proxies are not supported
    proxyAuth = ""
    tokenCount = 10
    # minimum amount of usable tokens. tokens are used to authorize API requests,
    # but they expire after ~1 hour, and have a limit of 187 requests.
    # the limit gets reset every 15 minutes, and the pool is filled up so there's
    # always at least $tokenCount usable tokens. again, only increase this if
    # you receive major bursts all the time
    # Change default preferences here, see src/prefs_impl.nim for a complete list
    [Preferences]
    theme = "Nitter"
    replaceTwitter = "twitter.mlyxshi.com"
    replaceYouTube = "youtube.mlyxshi.com"
    replaceReddit = "reddit.mlyxshi.com"
    replaceInstagram = ""
    proxyVideos = true
    hlsPlayback = true
    infiniteScroll = true
  '';
in
{

  virtualisation.oci-containers.containers = {
    "nitter" = {
      image = "quay.io/unixfox/nitter";
      dependsOn = [ "nitter-db" ];
      volumes = [
        "/var/lib/nitter:/data"
      ];
      extraOptions = lib.concatMap (x: [ "--label" x ]) [
        "io.containers.autoupdate=registry"
        "traefik.enable=true"
        "traefik.http.routers.websecure-nitter.rule=Host(`twitter.${config.networking.domain}`)"
        "traefik.http.routers.websecure-nitter.entrypoints=websecure"
      ];
    };

    "nitter-db" = {
      image = "redis:alpine";
      volumes = [
        "/var/lib/nitter-db:/data"
      ];
      cmd = [ "redis-server" "--save" "60" "1" "--loglevel" "warning" ];
    };

  };

  systemd.services.podman-nitter-db = {
    serviceConfig.StateDirectory = "nitter-db";
    preStart = ''
      mkdir -p /var/lib/nitter
      cat ${NitterConfig} > /var/lib/nitter/nitter.conf
    '';
  };

  system.activationScripts.cloudflare-dns-sync-nitter = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync twitter.${config.networking.domain}";
  };

}
