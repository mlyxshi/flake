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
    rev = "e21e5c67a828bea083387417d9a73d521141392f";
    hash = "sha256-c1aRFNePH6kpIk6I2dwAKK09nBnbG7SEWTUaQEuW7K0=";
  };

  vendorHash = "sha256-wh8x0klI28qDL/JrHGGxHMHTplBguoUPCyeasI9s76Q=";
  proxyVendor = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.appVersion=${version}"
  ];

  # postInstall = ''
  #   mv $out/bin/cmd $out/bin/hysteria
  # '';

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