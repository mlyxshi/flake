{ linuxKernel }:
linuxKernel.manualConfig rec {
  version = "6.12.5";
  src = builtins.fetchurl {
    url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${version}.tar.xz";
    sha256 = "sha256:1k9bc0lpgg29bh7zqz3pm91hhjnfyl5aw6r6hph3ha743k77y81r";
  };
  configfile = ./config;
}
