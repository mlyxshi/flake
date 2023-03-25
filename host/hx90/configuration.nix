{ config, lib, pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./filesystem.nix
  ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    firewall.enable = false;
  };

  systemd.network.networks = {
    dhcp = {
      name = "eno1";
      DHCP = "yes";
    };
  };


  virtualisation.podman.enable = true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  environment.systemPackages = [
    pkgs.python3
  ];


}
