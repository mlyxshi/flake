{ pkgs, lib, config, nixpkgs, self, ... }: {

  networking.hostName = "github-action-darwin";

  users.users.runner.home = "/Users/runner";
  users.users.runner.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe" ];

  environment.systemPackages = with pkgs;[
    helix
    joshuto
    cloudflared
    htop
  ];

  nix = {
    package = pkgs.nixVersions.unstable;
    registry.nixpkgs.flake = nixpkgs;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "runner" ];
    };
   
    linux-builder.enable = true;
  };

  services.nix-daemon.enable = true;

  nixpkgs.config.allowUnfree = true;


  # programs.ssh = {
  #   knownHosts = {
  #     github = {
  #       hostNames = [ "github.com" ];
  #       publicKey =
  #         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  #     };
  #   };
  # };
}
