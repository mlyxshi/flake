{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "commit-notifier";
  version = "unstable-2026-01-03";

  src = fetchFromGitHub {
    owner = "linyinfeng";
    repo = "commit-notifier";
    rev = "21c6617645d1bdb0ce213f14053665e3474756bd";
    hash = "sha256-iKdqHMI+TJNbxxmFC/SP6DMCh1EiTWAnrXJ0Q6iSK6g=";
  };

  cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  meta = {
    description = "A simple bot tracking git commits/PRs/issues/branches";
    homepage = "https://github.com/linyinfeng/commit-notifier";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "commit-notifier";
  };
}
