{ rustPlatform, fetchFromGitHub, pkg-config, openssl, sqlite }:

rustPlatform.buildRustPackage {
  pname = "commit-notifier";
  version = "unstable-2024-04-13";
  src = fetchFromGitHub ({
    owner = "linyinfeng";
    repo = "commit-notifier";
    rev = "fb2871be21823b583ecafceb141eef73f1cf50fb";
    sha256 = "sha256-gnYsTbppEiB9Tk9eUdmUWiwxtR6pwJwaLic768ayNx4=";
  });

  cargoSha256 = "sha256-QUlGzDP0RE4BquLDS1kSboAeV/BaHP6OC6hQ1big4/w=";

  buildInputs = [ openssl sqlite ];

  nativeBuildInputs = [ pkg-config ];

  meta.platforms = [ "aarch64-linux" ];
}
