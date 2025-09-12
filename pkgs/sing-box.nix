{ lib, buildGoModule, fetchFromGitHub, }:

buildGoModule rec {
  pname = "sing-box";
  version = "1.12.5";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "v${version}";
    hash = "sha256-LTORUt3/Q8eyfMkWjk/ixyRHB8NGvthbIJdcgOR3WaA=";
  };

  vendorHash = "sha256-XoHIxsJaFkC/Qz0+9AXWL+LBiTFUYKDtMqNseruAqZY=";

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
