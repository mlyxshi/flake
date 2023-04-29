final: prev: {
  Anime4k = prev.callPackage ../pkgs/Anime4k { };

  PingFang = prev.callPackage ../pkgs/Fonts/PingFang { };
  SF-Pro = prev.callPackage ../pkgs/Fonts/SF-Pro { };

  nodestatus-client = prev.callPackage ../pkgs/nodestatus-client { };
  snell-server = prev.callPackage ../pkgs/snell { };

  transmission = prev.callPackage ../pkgs/transmission { };
}
