{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "nodestatus-client";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "cokemine";
    repo = "nodestatus-client-go";
    rev = "v${version}";
    hash = "sha256-xV57eFxwrC+5iNTml1EBEQ5uJrdh35tDq8LCxEkQBqU=";
  };

  vendorHash = "sha256-mMRAWSUY4YVdgaELuU+ojf6okFwh7FRGp/txyB8jmOM=";

  meta = {
    description = "nodestatus-client-go";
    homepage = "https://github.com/cokemine/nodestatus-client-go";
  };
}
