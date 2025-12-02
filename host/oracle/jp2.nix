{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.prometheus
    self.nixosModules.services.transmission.default

    self.nixosModules.containers.podman
    self.nixosModules.containers.miniflux
    self.nixosModules.containers.change-detection
    self.nixosModules.containers.komari-monitor
  ];


  environment.systemPackages = with pkgs; [
    nix-index
    hath-rust

    (pkgs.writeShellScriptBin "update-index" ''
      filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr A-Z a-z)"
      mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
      # -N will only download a new version if there is an update.
      wget -q -N https://github.com/Mic92/nix-index-database/releases/latest/download/$filename
      ln -f $filename files
    '')
  ];

  systemd.services.hath = {
    serviceConfig.ExecStart = "${pkgs.hath-rust}/bin/hath-rust";
    serviceConfig.StateDirectory = "hath";
    serviceConfig.WorkingDirectory = "%S/hath";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" "hath-init.service" ];
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.hath-init = {
    unitConfig.ConditionPathExists = "!/var/lib/hath/data/client_login";
    script = ''
      mkdir -p /var/lib/hath/data/
      cat /secret/hath > /var/lib/hath/data/client_login 
    '';
    serviceConfig.Type = "oneshot";
    wantedBy = [ "multi-user.target" ];
  };

}
