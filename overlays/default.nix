final: prev: {
  Anime4k = prev.callPackage ../pkgs/anime4k { };

  PingFang = prev.callPackage ../pkgs/Fonts/PingFang { };
  SF-Pro = prev.callPackage ../pkgs/Fonts/SF-Pro { };

  nodestatus-client = prev.callPackage ../pkgs/nodestatus-client { };
  cloudflare-dns-sync = prev.callPackage ../pkgs/cloudflare-dns-sync { };

  snell-server = prev.callPackage ../pkgs/snell { };

  transmission = prev.callPackage ../pkgs/transmission { };
}
