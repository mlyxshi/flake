{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "1.0.31";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = "e24eb93c53bb7ad270a37f6e08619014156d0b43";
    hash = "";
  };

  vendorHash = "";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;

  meta.homepage = "https://github.com/komari-monitor/komari-agent";
}
