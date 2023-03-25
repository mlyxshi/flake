{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.transmission
  ];

  networking.nftables.enable = lib.mkForce false;

  # # snell-server hardcode /lib/ld-linux-aarch64.so.1
  # system.activationScripts.ldso = lib.stringAfter [ "usrbinenv" ] ''
  #   mkdir -m 0755 -p /lib
  #   ln -sfn ${pkgs.glibc}/lib/ld-linux-aarch64.so.1  /lib/ld-linux-aarch64.so.1 
  # '';


  # environment.systemPackages = with pkgs; [
  #   snell-server
  # ];



}
