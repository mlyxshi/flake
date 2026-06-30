{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  versionCheckHook,
  writeShellScript,
  nix-update,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snell-server";
  version = "6.0.0b4";

  src =
    let
      selectSystem = attrs: attrs.${stdenv.hostPlatform.system};
      arch = selectSystem {
        x86_64-linux = "amd64";
        aarch64-linux = "aarch64";
      };
    in
    fetchzip {
      url = "https://dl.nssurge.com/snell/snell-server-v${finalAttrs.version}-linux-${arch}.zip";
      hash = selectSystem {
        x86_64-linux = "sha256-EHtJUmFmYYSJPc4D0DOaNEhvAQL2nJHzjuAIUtlRkos=";
        aarch64-linux = "sha256-C+W69jh08mSjRKWsN3Og+sl3iTnFs02+IjlGr6ByuKs=";
      };
    };

  nativeBuildInputs = [
    autoPatchelfHook
    versionCheckHook
  ];

  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  installPhase = ''
    runHook preInstall

    install -Dm755 snell-server $out/bin/snell-server

    runHook postInstall
  '';

  doInstallCheck = true;

  passthru.updateScript = writeShellScript "update-snell-server" ''
    latestVersion=$(curl --fail --silent https://kb.nssurge.com/surge-knowledge-base/release-notes/snell | grep -oE 'snell-server-v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/snell-server-v//' | sort -V | tail -n1)
    if [[ "$latestVersion" == "$UPDATE_NIX_OLD_VERSION" ]]; then exit 0; fi
    ${lib.getExe nix-update} pkgsCross.gnu64.snell --version "$latestVersion"
    ${lib.getExe nix-update} pkgsCross.aarch64-multiplatform.snell --version skip
  '';

  meta = {
    homepage = "https://kb.nssurge.com/surge-knowledge-base/release-notes/snell";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "snell-server";
  };
})