{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "1.0.31";

  src = fetchFromGitHub {
    owner = "mlyxshi";
    repo = "komari-agent";
    rev = "662fae7173d359ba73a18bb4e62dd6b419c921e5";
    hash = "sha256-lCzdmVWso5jT5IsYVGQg0ppTGOYjkCz8A526x3JRpuM=";
  };

  vendorHash = "sha256-Wt2A3rGnY8vpdbWRz9tWBz+PcVxATCjjCwm/YXQz1RY=";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;

  meta.homepage = "https://github.com/komari-monitor/komari-agent";
}
