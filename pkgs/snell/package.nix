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
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "snell-server";
  inherit (sources) version;

  src = fetchurl source;

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
