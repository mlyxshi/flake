{ stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation rec {
  pname = "snell";
  version = "5.0.1";

  src = fetchzip {
    url = "https://dl.nssurge.com/snell/snell-server-v${version}-linux-amd64.zip";
    hash = "sha256-J2kRVJRC0GhxLMarg7Ucdk8uvzTsKbFHePEflPjwsHU=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp snell-server $out/bin/snell-server
  '';

  meta.description = "https://kb.nssurge.com/surge-knowledge-base/zh/release-notes/snell";
  meta.platforms = [ "x86_64-linux" ];
}
