{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "1.0.71";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = version;
    hash = "sha256-orbtNsU90rQ/tVxx3tyC1tCaF6t0VfQ7SO3+n1dEFus=";
  };

  vendorHash = "sha256-775c+PxFYnitqVbP5dbLpWzHoDCFKDuoVAV/hcvQFqE=";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;
}
