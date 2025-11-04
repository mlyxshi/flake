{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "1.1.33";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = version;
    hash = "sha256-BQZwEDjR69+Tvdtoj1mjp8cpTTl0ge2YUQwYtMDLQJE=";
  };

  vendorHash = "sha256-5RL/dDR/Or9GRCPVQmUYKTV82q7xuN2Mqc4/86WmbqY=";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;
}
