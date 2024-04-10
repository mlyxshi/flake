{ rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage rec {
  pname = "xremap";
  version = "0.8.18";

  src = fetchFromGitHub {
    owner = "xremap";
    repo = "xremap";
    rev = "v${version}";
    hash = "sha256-RR8SgnlQX8Gz9qwO/wN5NvFWsEQ/vvNdmOxxFojri90=";
  };

  cargoHash = "sha256-9L3kt/gzhKrpBXVbjg3XP1+H3vsc2ANwM1rPWMgXCf4=";

  # only enable kde client
  cargoBuildFlags = [ "--features kde" ];

  meta.platforms = [ "x86_64-linux" "aarch64-linux" ];
}
