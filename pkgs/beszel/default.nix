{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "beszel";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "henrygd";
    repo = "beszel";
    tag = "v${version}";
    hash = "";
  };

  installPhase = ''
    mkdir -p $out/bin
  '';


  meta = {
    homepage = "https://github.com/henrygd/beszel";
    description = "Lightweight server monitoring hub with historical data, docker stats, and alerts";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
