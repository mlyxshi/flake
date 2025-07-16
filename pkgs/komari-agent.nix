{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "0.0.24";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = version;
    hash = "sha256-zgzG73cTHxa17T20cOPgyoGqMgQZm13g8FmYjDqbI6E=";
  };

  # src = ../source/komari-agent;

  vendorHash = "sha256-2tCYq7+r2VCQTULEt7gkK3ocz3YSoKi9yZ7NCVUTiH8=";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;

  meta.homepage = "https://github.com/komari-monitor/komari-agent";

}
