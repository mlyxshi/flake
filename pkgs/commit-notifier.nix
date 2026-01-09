{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  sqlite,
  libgit2,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "commit-notifier";
  version = "0-unstable-2026-01-03";
  src = fetchFromGitHub ({
    owner = "linyinfeng";
    repo = "commit-notifier";
    rev = "21c6617645d1bdb0ce213f14053665e3474756bd";
    sha256 = "sha256-iKdqHMI+TJNbxxmFC/SP6DMCh1EiTWAnrXJ0Q6iSK6g=";
  });

  cargoHash = "sha256-OTXNRVEHT8cor76mNTbstb0GZBPal9qlie1wz2W5gpA=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    sqlite
    libgit2
    openssl
  ];

  meta = {
    description = "A simple telegram bot monitoring commit status.";
    homepage = "https://github.com/linyinfeng/commit-notifier";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      mlyxshi
    ];
    mainProgram = "commit-notifier";
  };

})
