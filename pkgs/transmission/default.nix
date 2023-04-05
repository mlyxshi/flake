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
  version = "4.0.2";
  src = fetchFromGitHub {
    owner = "transmission";
    repo = "transmission";
    fetchSubmodules = true;
    rev = version;
    hash = "sha256-DaaJnnWEZOl6zLVxgg+U8C5ztv7Iq0wJ9yle0Gxwybc=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    openssl
    curl
    python3
    systemd
  ];

  configurePhase = ''
    # Many PT sites limit allowed clients to a specific version, so fake version to 400
    sed -i 's/set(TR_VERSION_MAJOR "[0-9]\+")/set(TR_VERSION_MAJOR "4")/' CMakeLists.txt
    sed -i 's/set(TR_VERSION_MINOR "[0-9]\+")/set(TR_VERSION_MINOR "0")/' CMakeLists.txt
    sed -i 's/set(TR_VERSION_PATCH "[0-9]\+")/set(TR_VERSION_PATCH "0")/' CMakeLists.txt

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
    cp -r ../web/public_html         $out   
  '';
}
