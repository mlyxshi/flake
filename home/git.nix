{ pkgs, lib, config, ... }: {
  programs.git = {
    enable = true;
    userName = "mlyxshi";
    userEmail = "mlyxdev@gmail.com";

    delta.enable = true;

    ignores = [
      ".DS_Store"
      ".vscode"
    ];

    extraConfig = {
      init.defaultBranch = "main";
    } // lib.optionalAttrs pkgs.stdenv.isDarwin {
      # ssh signatures
      # https://blog.dbrgn.ch/2021/11/16/git-ssh-signatures/
      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe";
      gpg.format = "ssh";
      commit.gpgsign = "true";
    };
  };
}
