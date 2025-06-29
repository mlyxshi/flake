{ stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation rec {
  pname = "snell";
  version = "5.0.0b1";

  src = fetchzip {
    url =
      if stdenvNoCC.hostPlatform.isx86_64
      then "https://dl.nssurge.com/snell/snell-server-v${version}-linux-amd64.zip"
      else "https://dl.nssurge.com/snell/snell-server-v${version}-linux-aarch64.zip";
    hash =
      if stdenvNoCC.hostPlatform.isx86_64
      then ""
      else "";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp snell-server $out/bin/snell-server
  '';

  meta.description = "https://manual.nssurge.com/others/snell.html";
}
