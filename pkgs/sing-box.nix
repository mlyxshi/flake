{ lib, buildGoModule, fetchFromGitHub, }:

buildGoModule rec {
  pname = "sing-box";
  version = "1.12.1";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "v${version}";
    hash = "sha256-fo5xO081IX+rPA5yZ0P2dxSZsVHsBTJeCJmI0dSgGyE=";
  };

  vendorHash = "sha256-sWWiPDUEc+EBzLmd+QYYVdecqhKBeKkPABEp6jFqraw=";

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
