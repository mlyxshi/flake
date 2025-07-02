{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "komari-agent";
  version = "0.0.21";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = version;
    hash = "sha256-x7vT1aApWxV70V0hCjeBmk+qfFgaQuWR/eHg6E418l8=";
  };

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  ldflags = [ "-s" "-w" ];

  meta = {
    homepage = "https://github.com/komari-monitor/komari-agent";
    mainProgram = "komari-agent";
  };
}
