{ rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage rec {
  pname = "tcpping";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "BlackLuny";
    repo = "tcpping";
    rev = "v${version}";
    hash = "sha256-r15z0agM3waeDJlt6Q/IIMrki5QsbcSWfztP1kt3id4=";
  };

  meta.platforms = [ "x86_64-linux" "aarch64-linux" ];
}
