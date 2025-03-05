{ stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation rec {
  pname = "snell";
  version = "4.1.1";

  src = fetchzip {
    url = "https://dl.nssurge.com/snell/snell-server-v${version}-linux-amd64.zip";
    hash = "sha256-IcW13oq2SC+XeCwUVU2ZVkjYe0V29gczYFz+YXhZgWU=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp snell-server $out/bin/snell-server
  '';

  meta = {
    description = "https://manual.nssurge.com/others/snell.html";
    platforms = [ "x86_64-linux" ];
  };
}