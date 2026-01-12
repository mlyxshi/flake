{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  upx,
}:
let
  sources = import ./sources.nix;
  system = stdenv.hostPlatform.system;
in
stdenv.mkDerivation {
  pname = "snell-server";
  inherit (sources) version;

  src = fetchurl sources.${system};

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
