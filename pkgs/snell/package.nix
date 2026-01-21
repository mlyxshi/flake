{
  lib,
  stdenv,
  fetchurl,
  unzip,
  upx,
  autoPatchelfHook,
}:
let
  sources = import ./sources.nix;
  source = sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "snell-server";
  inherit (sources) version;

  src = fetchurl source;

  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
    upx
    autoPatchelfHook
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
  ];

  installPhase = ''
    upx -d snell-server
    install -Dm755 snell-server $out/bin/snell-server
  '';
}
