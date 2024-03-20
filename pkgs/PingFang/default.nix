{ stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation {
  pname = "PingFang";
  version = "1.0";

  src = fetchzip {
    name = "PingFang";
    url =
      "https://github.com/mlyxshi/Ping-Fang/releases/download/v1.0/release.zip";
    hash = "sha256-uhfp7hHmRv/8VuqEzMZeNaGQCtYj3S56Q2ATBaIFmB0=";
    stripRoot = false;
  };

  installPhase = ''
    install -m444 -Dt  $out/share/fonts/truetype  *.ttf
  '';

  meta = {
    description = "PingFang <-- Apple default font for Chinese";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
