{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "komari-agent";
  version = "0.0.22";

  src = fetchFromGitHub {
    owner = "komari-monitor";
    repo = "komari-agent";
    rev = version;
    hash = "sha256-6ICnWVFJm3wg/zFvn441nN0XLp8DeqB+xtG2i8SZYYU=";
  };

  vendorHash = "sha256-4KX1fQJTOdJ0HCHIhD0gplD+htmJc8OcBA2kibQCpJ8=";

  ldflags = [ "-s" "-w" "-X github.com/komari-monitor/komari-agent/update.CurrentVersion=${version}" ];

  doCheck = false;

  meta = {
    homepage = "https://github.com/komari-monitor/komari-agent";
  };
}
