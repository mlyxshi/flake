{ stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation rec {
  pname = "snell";
  version = "5.0.0b3";

  src = fetchzip {
    url =
      if stdenvNoCC.hostPlatform.isx86_64
      then "https://dl.nssurge.com/snell/snell-server-v${version}-linux-amd64.zip"
      else "https://dl.nssurge.com/snell/snell-server-v${version}-linux-aarch64.zip";
    hash =
      if stdenvNoCC.hostPlatform.isx86_64
      then "sha256-DjEfcFRLEhjvuru/hnO93Y3wgu8IcegH6ylcZndV+js="
      else "sha256-imp36CgZGQeD4eWf+kPep55sM42lHQvwDobfVV9ija0=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp snell-server $out/bin/snell-server
  '';

  meta.description = "https://kb.nssurge.com/surge-knowledge-base/zh/release-notes/snell";
}
