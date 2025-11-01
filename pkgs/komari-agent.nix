{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "1.1.31";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = version;
    hash = "sha256-PR8Ks1HSLSOrIyrmMFrb7yEHq/D5FIoT8AIDThQfgTw=";
  };

  vendorHash = "sha256-m2XD3KgMnetpgDontK8Kk+PRHcqM2eLV2NvikR5zAWg=";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;
}
