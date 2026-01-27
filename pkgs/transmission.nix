{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "transmission";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "transmission";
    repo = "transmission";
    rev = "272401184f0736e6063f9da90be7d037e907508a";
    hash = "";
  };

  nativeBuildInputs = [
    cmake
  ];
})
