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
    fetchSubmodules = true;
    rev = "272401184f0736e6063f9da90be7d037e907508a";
    hash = "sha256-glmwa06+jCyL9G2Rc58Yrvzo+/6Qu3bqwqy02RWgG64=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    curl
  ];
})
