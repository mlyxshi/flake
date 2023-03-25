{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.shadowsocks
  ];

  environment.systemPackages = with pkgs; [
    terraform
  ];
}
