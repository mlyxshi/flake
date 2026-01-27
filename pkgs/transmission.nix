{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "transmission";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "transmission";
    repo = "transmission";
    tag = finalAttrs.version;
    hash = "sha256-glmwa06+jCyL9G2Rc58Yrvzo+/6Qu3bqwqy02RWgG64=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    curl
  ];
})
