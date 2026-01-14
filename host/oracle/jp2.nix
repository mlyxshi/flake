{
  self,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    self.nixosModules.services.prometheus
    self.nixosModules.services.transmission.default
    self.nixosModules.services.hath
    self.nixosModules.services.commit-notifier

    self.nixosModules.containers.podman
    self.nixosModules.containers.miniflux
    self.nixosModules.containers.change-detection
    self.nixosModules.containers.komari-monitor
  ];

  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";
    inbounds = [
      {
        type = "anytls";
        tag = "anytls-in";
        listen = "0.0.0.0";
        listen_port = 8888;
        users = [
          {
            password = {
              _secret = "/secret/ss-password-2022";
            };
          }
        ];
        tls = {
          enable = true;
          insecure = false;
        };
      }
    ];
  };

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
