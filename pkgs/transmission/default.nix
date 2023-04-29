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
  version = "4.0.3";
  src = fetchFromGitHub {
    owner = "transmission";
    repo = "transmission";
    fetchSubmodules = true;
    rev = version;
    hash = "sha256-P7omd49xLmReo9Zrg0liO1msUVzCa5CxH7PGmH4oPzg=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    openssl
    curl
    python3
    systemd
  ];

  # Many PT sites limit allowed clients to a specific version, so fake version to 300
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
}
