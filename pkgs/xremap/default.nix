{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "xremap";
  version = "unstable-2024-03-19";

  src = fetchFromGitHub {
    # only enable kde client
    owner = "xremap";
    repo = "xremap";
    rev = "8dede9f0b169eb3f50f65487be7a9e5b5d846eb8";
    hash = "sha256-kXLNz9vZUFwvXc4xZWN8LOU1LaZVLm3MYXR2MPfR88U=";
  };

  cargoHash = "sha256-mfmn9sOmDWHyKJzdSDNUaFG/hTK94+MV00jG3Z5QT/E=";

  cargoBuildFlags = [ "--features kde" ];

  meta.platforms = [ "x86_64-linux" "aarch64-linux" ];
}
