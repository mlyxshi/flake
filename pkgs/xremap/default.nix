{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "xremap";
  version = "0.8.13";

  src = fetchFromGitHub {
    # only enable kde client
    owner = "k0kubun";
    repo = "xremap";
    rev = "v${version}";
    hash = "sha256-hErjvNZNjsWNeeRVPdEfOQxJPtJCDLvCm8V7SHzXHws=";
  };

  cargoHash = "sha256-ukVUM//6Ln4EjMnNJhRtfJ/pV2kfxfjnMMMkEVHVQCw=";

  cargoBuildFlags = [
    "--features kde"
  ];

  meta.platforms = [
    "x86_64-linux"
    "aarch64-linux"
  ];
}
