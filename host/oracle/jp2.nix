{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.prometheus
    self.nixosModules.services.transmission.default
    
    self.nixosModules.containers.podman
    self.nixosModules.containers.miniflux
    self.nixosModules.containers.change-detection
  ];

  environment.systemPackages = with pkgs; [
    nix-index

    (pkgs.writeShellScriptBin "update-index" ''
      filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr A-Z a-z)"
      mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
      # -N will only download a new version if there is an update.
      wget -q -N https://github.com/Mic92/nix-index-database/releases/latest/download/$filename
      ln -f $filename files
    '')
  ];

}
