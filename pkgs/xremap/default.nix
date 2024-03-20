{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "xremap";
  version = "0.8.14";

  src = fetchFromGitHub {
    # only enable kde client
    owner = "xremap";
    repo = "xremap";
    rev = "v${version}";
    hash = "sha256-GexVY76pfmHalJPiCfVe9C9CXtlojG/H6JjOiA0GF1c=";
  };

  cargoHash = "sha256-ABzt8PMsas9+NRvpgtZlsoYjjvwpU8f6lqhceHxq91M=";

  cargoBuildFlags = [ "--features kde" ];

  meta.platforms = [ "x86_64-linux" "aarch64-linux" ];
}
