{ self, pkgs, lib, config, modulesPath, ... }: {
  imports = [
    self.nixosModules.services.transmission
  ];

  systemd.services.applestore = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "/root/.nix-profile/bin/java -jar /apple-monitor-v0.1.1.jar";
    };
  };

}
