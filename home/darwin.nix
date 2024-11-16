{ self, lib, ... }: {
  imports = [
    ./.
  ];

  home = {
    username = "dominic";
    homeDirectory = "/Users/dominic";
  };
}
