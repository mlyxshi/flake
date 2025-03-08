{ stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation rec {
  pname = "snell";
  version = "4.1.1";

  src = fetchzip {
    url =
      if stdenvNoCC.hostPlatform == "x86_64-linux"
      then "https://dl.nssurge.com/snell/snell-server-v${version}-linux-amd64.zip"
      else "https://dl.nssurge.com/snell/snell-server-v${version}-linux-aarch64.zip";
    hash =
      if stdenvNoCC.hostPlatform == "x86_64-linux"
      then "sha256-IcW13oq2SC+XeCwUVU2ZVkjYe0V29gczYFz+YXhZgWU="
      else "sha256-ogZBC/Bjo7sdZlKQz+5T/JCPAUS4Ce4n99G3oMdbUe4=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp snell-server $out/bin/snell-server
  '';

  meta = {
    description = "https://manual.nssurge.com/others/snell.html";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
