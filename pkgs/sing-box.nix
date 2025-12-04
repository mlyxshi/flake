{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "sing-box";
  version = "1.12.12";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "v${version}";
    hash = "sha256-4TQLaDjZYcm8FVBo06c4rKuXEO2xRGm6cIzpkPwtL/g=";
  };

  vendorHash = "sha256-R9dN2/MmuAeYB9UkNDbhc48SelBMR80nMnptNKD0y9c=";

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
