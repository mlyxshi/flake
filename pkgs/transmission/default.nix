{ stdenv
, fetchFromGitHub
, cmake
, openssl
, curl
, python3
, systemd
}:
stdenv.mkDerivation rec {
  pname = "transmission";
  version = "4.0.4";
  src = fetchFromGitHub {
    owner = "transmission";
    repo = "transmission";
    fetchSubmodules = true;
    rev = version;
    hash = "sha256-Sz3+5VvfOgET1aiormEnBOrF+yN79tiSQvjLAoGqTLw=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    openssl
    curl
    python3
    systemd
  ];

  # Many PT sites limit allowed clients to some specific versions(bullshit rules), so fake version to 300
  # https://github.com/transmission/transmission/commit/bb6b5a062ee594dfd4b7a12a6b6e860c43849bfd
  configurePhase = ''
    sed -i 's/set(TR_USER_AGENT_PREFIX "''${TR_SEMVER}")/set(TR_USER_AGENT_PREFIX "3.00")/' CMakeLists.txt
    sed -i 's/string(APPEND TR_PEER_ID_PREFIX "-")/set(TR_PEER_ID_PREFIX "-TR3000-")/' CMakeLists.txt

    # Disable CSRF
    sed -i '/#define REQUIRE_SESSION_ID/d'  libtransmission/rpc-server.cc

    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release ..
  '';

  buildPhase = ''
    make -j4
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./daemon/transmission-daemon  $out/bin
    cp ./utils/transmission-remote   $out/bin
    cp -r ../web/public_html         $out   
  '';

  meta.platforms = [
    "x86_64-linux"
    "aarch64-linux"
  ];
}
