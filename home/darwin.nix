{ self, lib, ... }: {
  imports = [ 
    ./. 
    ./firefox
  ];

  home = {
    username = "dominic";
    homeDirectory = "/Users/dominic";
  };

  programs.firefox.package = null;
}
