{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "xremap";
  version = "0.8.13";

  src = fetchFromGitHub {
    owner = "k0kubun";
    repo = "xremap";
    rev = "v${version}";
    hash = "";
  };

  cargoHash = "";

  meta.platforms = [
    "x86_64-linux"
    "aarch64-linux"
  ];
}