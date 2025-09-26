{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "1.0.83";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = version;
    hash = "sha256-wu3YKIh0ZivH4VXLfkd3cjQi8uQXJLYd3T3XXrFbkpc=";
  };

  vendorHash = "sha256-775c+PxFYnitqVbP5dbLpWzHoDCFKDuoVAV/hcvQFqE=";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;
}
