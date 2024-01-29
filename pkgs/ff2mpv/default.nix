{ lib, stdenv, fetchFromGitHub, python3, mpv }:

stdenv.mkDerivation rec {
  pname = "ff2mpv";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "woodruffw";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Xx18EX/MxLrnwZGwMFZJxJURUpjU2P01CQue5XbZ3fw=";
  };

  buildInputs = [ python3 mpv ];

  postPatch = ''
    patchShebangs .
    substituteInPlace ff2mpv.json \
      --replace '/home/william/scripts/ff2mpv' "$out/bin/ff2mpv.py"
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib/mozilla/native-messaging-hosts
    cp ff2mpv.py $out/bin
    cp ff2mpv.json $out/lib/mozilla/native-messaging-hosts
  '';

  meta.platforms = [
    "aarch64-darwin"
    "x86_64-linux"
    "aarch64-linux"
  ];
}
