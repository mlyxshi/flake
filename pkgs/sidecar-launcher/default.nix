{ stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation rec {
  pname = "sidecar-launcher";
  version = "1.2";

  src = fetchzip {
    url = "https://github.com/Ocasio-J/SidecarLauncher/releases/download/${version}/SidecarLauncher.zip";
    hash = "sha256-iwEAGgibl4z/UdqBXiT3zQqNRP763X/iAV3LuUf2zmI=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp SidecarLauncher $out/bin/sidecar-launcher
  '';

  meta = {
    description = "CLI to connect to a Sidecar device";
    homepage = "https://github.com/Ocasio-J/SidecarLauncher";
    platforms = [ "aarch64-darwin" ];
  };
}
