{ stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation rec {
  pname = "snell";
  version = "4.1.1";

  src = fetchzip {
    url = "https://dl.nssurge.com/snell/snell-server-${version}-linux-amd64.zip";
    hash = "1qjpj8w6rzla96gdvlky3zjk5n6b6rzdcn6b61p6p19v5m1b33ys";
  };

  installPhase = ''

  '';

  meta = {
    description = "https://manual.nssurge.com/others/snell.html";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
