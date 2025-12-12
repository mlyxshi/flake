{ stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation rec {
  pname = "snell";
  version = "5.0.1";

  src = fetchzip {
    url =
      if stdenvNoCC.hostPlatform.isx86_64
      then "https://dl.nssurge.com/snell/snell-server-v${version}-linux-amd64.zip"
      else "https://dl.nssurge.com/snell/snell-server-v${version}-linux-aarch64.zip";
    hash =
      if stdenvNoCC.hostPlatform.isx86_64
      then "sha256-UT+Rd6TEMYL/+xfqGxGN/tiSBvN8ntDrkCBj4PuMRwg="
      else "sha256-J2kRVJRC0GhxLMarg7Ucdk8uvzTsKbFHePEflPjwsHU=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp snell-server $out/bin/snell-server
  '';

  meta.description = "https://kb.nssurge.com/surge-knowledge-base/zh/release-notes/snell";
}
