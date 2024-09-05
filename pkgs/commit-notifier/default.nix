{ rustPlatform, fetchFromGitHub, pkg-config, openssl, sqlite }:
rustPlatform.buildRustPackage {
  pname = "commit-notifier";
  version = "unstable-2024-09-05";
  src = fetchFromGitHub {
    owner = "linyinfeng";
    repo = "commit-notifier";
    rev = "fb2871be21823b583ecafceb141eef73f1cf50fb";
    sha256 = "sha256-gnYsTbppEiB9Tk9eUdmUWiwxtR6pwJwaLic768ayNx4=";
  };

  cargoHash = "sha256-NOLpBns6gL8evD6zRfYTvExoZMWEiLbifmAXhhmiA5I=";

  buildInputs = [ openssl sqlite ];

  nativeBuildInputs = [ pkg-config ];

  meta.platforms = [ "aarch64-linux" ];
}
