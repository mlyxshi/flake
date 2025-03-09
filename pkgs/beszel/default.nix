{ buildGo124Module, fetchFromGitHub }:
buildGo124Module rec {
  pname = "beszel";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "henrygd";
    repo = "beszel";
    tag = "v${version}";
    hash = "sha256-4RuYZcBR7X9Ug6l91N/FtyfT38HlW2guputzo4kF8YU=";
  };

  sourceRoot = "${src.name}/beszel";
  vendorHash = "sha256-VX9mil0Hdmb85Zd9jfvm5Zz2pPQx+oAGHY+BI04bYQY=";

  installPhase = ''
    mkdir -p $out/bin
  '';

  meta = {
    homepage = "https://github.com/henrygd/beszel";
    description = "Lightweight server monitoring hub with historical data, docker stats, and alerts";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
