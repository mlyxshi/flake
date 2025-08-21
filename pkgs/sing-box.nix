{ lib, buildGoModule, fetchFromGitHub, }:

buildGoModule rec {
  pname = "sing-box";
  version = "1.12.3";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "v${version}";
    hash = "sha256-OHhCC+tSDZRSDN9i3L6NtwgarBKHv+KGNyPhHttqo4g=";
  };

  vendorHash = "sha256-Y/UP2rbee4WSctelk9QddMXciucz5dNLOLDDWtEFfLU=";

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
