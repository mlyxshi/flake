{ stdenv, fetchzip, makeBinaryWrapper }:
stdenv.mkDerivation {
  pname = "snell";
  version = "4.0";

  src = fetchzip {
    name = "snell-server";
    url = "https://dl.nssurge.com/snell/snell-server-v4.0.0-linux-aarch64.zip";
    hash = "sha256-nb/b80m6pUkwxv8HouLIPFU515ts+Sp+zVfxNM9+FdQ=";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp snell-server $out/bin
    wrapProgram $out/bin/snell-server --set LD_LIBRARY_PATH ${stdenv.cc.cc.lib}/lib
  '';

  meta = {
    description = "https://manual.nssurge.com/others/snell.html";
  };
}
