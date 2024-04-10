{ rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage {
  pname = "commit-notifier";
  version = "unstable-2024-04-10";

  src = fetchFromGitHub {
    owner = "linyinfeng";
    repo = "commit-notifier";
    rev = "3c19ed52676d4387db59a2a47feb1038be9a781f";
    hash = "sha256-kfpOQWmgTbrDHiH7U3cFfOmuNCb7jVsdF38eKrLL3Qk=";
  };

  cargoHash = "sha256-P9EQIVKUfbyEi5qprrK8I0R++OxzdbZrG6qWXXyam90=";

  meta.platforms = [ "aarch64-linux" ];
}

