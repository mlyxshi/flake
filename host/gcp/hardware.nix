{ modulesPath, pkgs, lib, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.systemd.enable = true;

  boot.initrd.systemd.root = "gpt-auto";
  boot.initrd.supportedFilesystems = [ "ext4" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.timeout = 1;
  boot.loader.efi.canTouchEfiVariables = true;

  # block twitter ads.    https://www.v2ex.com/t/1129354
  networking.extraHosts = "2606:4700:4700::1001 api.twitter.com";

}
