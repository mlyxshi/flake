{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "1.1.40";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = version;
    hash = "sha256-aWCsaiYkpj0D9hr7V3pxSk14pMD2E117vwemt9Ckqv0=";
  };

  vendorHash = "sha256-5RL/dDR/Or9GRCPVQmUYKTV82q7xuN2Mqc4/86WmbqY=";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;
}
