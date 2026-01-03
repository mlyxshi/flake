{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  upx,
  # gcc,
  ...
}:

let
  platformMap = {
    "x86_64-linux" = "linux-amd64";
    "aarch64-linux" = "linux-aarch64";
  };
  system = stdenv.hostPlatform.system;
  platform = platformMap.${system} or (throw "Unsupported platform: ${system}");
  sha256s = {
    "x86_64-linux" = "sha256-J2kRVJRC0GhxLMarg7Ucdk8uvzTsKbFHePEflPjwsHU=";
    "aarch64-linux" = "sha256-UT+Rd6TEMYL/+xfqGxGN/tiSBvN8ntDrkCBj4PuMRwg=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "snell-server";
  version = "5.0.1";

  src = fetchzip {
    url = "https://dl.nssurge.com/snell/snell-server-v${finalAttrs.version}-${platform}.zip";
    sha256 = sha256s.${system};
  };

  nativeBuildInputs = [
    upx
    autoPatchelfHook
  ];
  # buildInputs = [
  #   gcc.cc.lib
  # ];
  installPhase = ''
    upx -d snell-server
    install -Dm755 snell-server $out/bin/snell-server
  '';

  meta = {
    description = "Snell is a lean encrypted proxy protocol developed by Surge team";
    homepage = "https://kb.nssurge.com/surge-knowledge-base/release-notes/snell";
    # license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = with lib.maintainers; [
      mlyxshi
    ];
    mainProgram = "snell-server";
  };
})
