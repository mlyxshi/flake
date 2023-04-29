{ stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation {
  pname = "SF-Pro";
  version = "1.0";

  src = fetchzip {
    name = "SF-Pro";
    url = "https://github.com/mlyxshi/SF-Pro/releases/download/v1.0/release.zip";
    hash = "sha256-UMNkYoSBGoKFkMlZ9ShGD3aZn8z2lEWHdugKHDlptdM=";
    stripRoot = false;
  };

  installPhase = ''
    install -m444 -Dt  $out/share/fonts/truetype  *.ttf
    install -m444 -Dt  $out/share/fonts/opentype  *.otf
  '';

  meta = {
    description = "SF-Pro <-- Apple default font for English";
  };
}
