{ fetchFromGitHub
, lib
, stdenvNoCC
}:

stdenvNoCC.mkDerivation {
  pname = "asahi-firmware";
  version = "m1-mini-13.5";

  src = fetchFromGitHub {
    owner = "mlyxshi";
    repo = "asahi-firmware";
    rev = "b979012acc315a171c1b02f29f4c7ac2d68223e0";
    hash = "sha256-gMekoMeHY7yuVJaFv3NrwJz0P9Ddh4n1GKKiPMvb/Lg=";
  };

  installPhase = ''
    mkdir -p $out/lib/firmware/
    cp -r * $out/lib/firmware/ 
  '';

  meta = with lib; {
    description = "apple firmware for asahi linux";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
    ];
  };
}
