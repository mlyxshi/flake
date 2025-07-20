{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = version;
    hash = "sha256-RhHyvaJTby4t1QP8U0g58lJSX+dUOjgyjdX8LdYsr64=";
  };

  vendorHash = "sha256-2tCYq7+r2VCQTULEt7gkK3ocz3YSoKi9yZ7NCVUTiH8=";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;

  meta.homepage = "https://github.com/komari-monitor/komari-agent";
}
