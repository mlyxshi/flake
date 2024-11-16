{ pkgs, lib, config, ... }: {

  networking.hostName = "ga";

  users.users.runner.home = "/Users/runner";
  users.users.runner.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe"
  ];

  environment.systemPackages = with pkgs; [
    helix
    joshuto
    htop
    fish
    starship
    eza
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      l = "eza -algh";
      r = "joshuto";
    };

    promptInit = ''eval (starship init fish)'';
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "runner" ];
    };
  };
}
