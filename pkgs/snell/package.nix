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
    runHook preUnpack

    unzip $src
    upx -d snell-server

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 snell-server $out/bin/snell-server

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Lean encrypted proxy protocol";
    homepage = "https://kb.nssurge.com/surge-knowledge-base/release-notes/snell";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = with lib.maintainers; [
      mlyxshi
    ];
    mainProgram = "snell-server";
  };
}
