{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "1.0.40";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = version;
    hash = "sha256-CAkszhqxjrhc4cyIZQBWGpbuCmcC1fLHUtofmjABnVM=";
  };

  vendorHash = "sha256-Wt2A3rGnY8vpdbWRz9tWBz+PcVxATCjjCwm/YXQz1RY=";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;
}
