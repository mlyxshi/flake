{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "1.0.32";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = version;
    hash = "sha256-Zh1YYDMZXw2KILhMemGWO/BcOxNaeJ1gCoDCkRQ/kAw=";
  };

  vendorHash = "";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;

  meta.homepage = "https://github.com/komari-monitor/komari-agent";
}
