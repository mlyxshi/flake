{ python3, fetchFromGitHub }:

let
  python = python3.override {
    packageOverrides = self: super: {
      sqlalchemy = super.sqlalchemy.overridePythonAttrs (old: rec {
        version = "1.4.47";
        src = self.fetchPypi {
          pname = "SQLAlchemy";
          inherit version;
          hash = "sha256-lfwC9/wfMZmqpHqKdXQ3E0z2GOnZlMhO/9U/Uww4WG8=";
        };
      });
    };
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "flexget";
  version = "3.5.33";
  format = "pyproject";

  # Fetch from GitHub in order to use `requirements.in`
  src = fetchFromGitHub {
    owner = "Flexget";
    repo = "Flexget";
    rev = "pull/3716/head";
    hash = "sha256-KXtfcRBlZXwQ+217FwpQj9dpjfDamNW7zDNUmwQqlRY=";
  };

  postPatch = ''
    # remove dependency constraints but keep environment constraints
    sed 's/[~<>=][^;]*//' -i requirements.txt
    # "zxcvbn-python" was renamed to "zxcvbn", and we don't have the former in
    # nixpkgs. See: https://github.com/NixOS/nixpkgs/issues/62110
    substituteInPlace requirements.txt --replace "zxcvbn-python" "zxcvbn"
  '';

  # ~400 failures
  doCheck = false;

  propagatedBuildInputs = with python.pkgs; [
    # See https://github.com/Flexget/Flexget/blob/master/requirements.txt
    apscheduler
    beautifulsoup4
    click
    colorama
    commonmark
    feedparser
    guessit
    html5lib
    jinja2
    jsonschema
    loguru
    more-itertools
    packaging
    psutil
    pynzb
    pyrss2gen
    python-dateutil
    pyyaml
    rebulk
    requests
    rich
    rpyc
    sqlalchemy
    typing-extensions

    # WebUI requirements

    # Plugins requirements
    transmission-rpc

    # extra
    cheroot
    portend
    aniso8601
    itsdangerous
    autocommand
    zipp
    jaraco_classes
  ];

  pythonImportsCheck = [
    "flexget"
  ];
}