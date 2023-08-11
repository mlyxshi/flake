{ lib
, fetchFromGitHub
, buildGoModule
}:
buildGoModule rec {
  pname = "hysteria";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "apernet";
    repo = "hysteria";
    rev = "2c7db032438be47577085e06e552245537720f35";
    hash = "sha256-l6DhiiCVn3Rf61bPLc9mKLsc9t4yUmx+giIsKZFwG6M=";
  };

  vendorHash = "sha256-KBA2Aq1WJM5y6w+NuImGTf22U2mVZrmIFvQuMQ4AGuY=";
  proxyVendor = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.appVersion=${version}"
  ];

  # Network required
  doCheck = false;

  meta = with lib; {
    description = "A feature-packed proxy & relay utility optimized for lossy, unstable connections";
    homepage = "https://github.com/apernet/hysteria";
    platforms = [
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}