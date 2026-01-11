{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  upx,
}:
let
  info = import ./version.nix;
  inherit (info) version hash;

  platformMap = {
    "x86_64-linux" = "linux-amd64";
    "aarch64-linux" = "linux-aarch64";
  };
  system = stdenv.hostPlatform.system;
  platform = platformMap.${system};
  fetchSrc = {
    url = "https://dl.nssurge.com/snell/snell-server-v${version}-${platform}.zip";
    hash = hash.${system};
  };
in
stdenv.mkDerivation {
  pname = "snell-server";
  inherit version;

  src = fetchurl fetchSrc;

  nativeBuildInputs = [
    unzip
    upx
    autoPatchelfHook
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
  ];

  unpackPhase = ''
    unzip $src
    upx -d snell-server
  '';

  installPhase = ''
    install -Dm755 snell-server $out/bin/snell-server
  '';
}
