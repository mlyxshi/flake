{ lib, buildGoModule, fetchFromGitHub, }:

buildGoModule rec {
  pname = "sing-box";
  version = "1.12.4";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "v${version}";
    hash = "sha256-Pc6aszIzu9GZha7I59yGasVVKHUeLPiW34zALFTM8Ec=";
  };

  vendorHash = "sha256-I/J1ht++GqxVlc83GxmLxzI7S980AbMwvrrVD867ll4=";

  tags = [
    "with_quic"
    "with_dhcp"
    "with_wireguard"
    "with_utls"
    "with_acme"
    "with_clash_api"
    "with_gvisor"
    "with_tailscale"
  ];

  subPackages = [
    "cmd/sing-box"
  ];

  ldflags = [
    "-X=github.com/sagernet/sing-box/constant.Version=${version}"
  ];

  meta.mainProgram = "sing-box";
}
