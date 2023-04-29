{ stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation rec {
  pname = "Anime4k";
  version = "4.0.1";

  src = fetchzip {
    url = "https://github.com/bloc97/Anime4K/releases/download/v${version}/Anime4K_v4.0.zip";
    hash = "sha256-9B6U+KEVlhUIIOrDauIN3aVUjZ/gQHjFArS4uf/BpaM=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir $out
    cp *.glsl $out
  '';

  meta = {
    description = "A High-Quality Real Time Upscaler for Anime Video";
  };
}
