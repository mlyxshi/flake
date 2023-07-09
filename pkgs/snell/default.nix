{ stdenv, fetchzip, makeBinaryWrapper }:
stdenv.mkDerivation {
  pname = "snell";
  version = "4.0.1";

  src = fetchzip {
    name = "snell-server";
    url = "https://dl.nssurge.com/snell/snell-server-v4.0.1-linux-aarch64.zip";
    hash = "sha256-gjbT+MBlguTN9jW4Z+CaluFxbEm3evD3rkIgtWkxbLk=";
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

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
