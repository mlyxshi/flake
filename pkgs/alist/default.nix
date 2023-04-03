{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "alist";
  version = "3.15.0";
  src = fetchzip {
    url = "https://github.com/alist-org/alist/releases/download/v${version}/alist-linux-musl-arm64.tar.gz";
    sha256 = "sha256-ph/OgpQfBBgDxvggzXQqjq3/FuxQSGVxBANyCcRdl0c=";
  };

  installPhase = ''
    mkdir -p $out/bin/
    cp alist $out/bin/
  '';
}