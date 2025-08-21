{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "1.0.50";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = version;
    hash = "sha256-1mTFkUgG8itvUVmEcf0Ktot+Sffc9QCpJhV6NHLddLs=";
  };

  vendorHash = "sha256-775c+PxFYnitqVbP5dbLpWzHoDCFKDuoVAV/hcvQFqE=";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;
}
