{ self, pkgs, lib, config, ... }: {
  # imports = [
  #   self.nixosModules.containers.podman
  # ];


  # networking.nftables.enable = true;
  # networking.nftables.ruleset = ''
  # '';  

  environment.systemPackages = with pkgs; [
    sing-box
  ];

}
