{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "1.0.72";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = version;
    hash = "sha256-J7uzyBSibFzW7al8JA3kGA8BpQyoC6eeyEz26UvAINg=";
  };

  vendorHash = "sha256-775c+PxFYnitqVbP5dbLpWzHoDCFKDuoVAV/hcvQFqE=";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;
}
