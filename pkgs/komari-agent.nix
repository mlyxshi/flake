{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "0.0.22";

  # src = fetchFromGitHub {
  #   owner = "komari-monitor";
  #   repo = "komari-agent";
  #   rev = version;
  #   hash = "sha256-6ICnWVFJm3wg/zFvn441nN0XLp8DeqB+xtG2i8SZYYU=";
  # };

  src = ../source/komari-agent;

  vendorHash = "sha256-o4WAD8p6cbepoNQTgMRtq8zIaKdd2rGHzc0hGuSJ1j0=";

  ldflags = [ "-s" "-w" ];

  doCheck = false;

  meta.homepage = "https://github.com/komari-monitor/komari-agent";

}
