# https://gist.github.com/dramforever/bf339cb721d25892034e052765f931c6
{ modulesPath, ... }:
{
  nix.settings.experimental-features = "flakes nix-command";

  # Hardware
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  fileSystems."/old-root" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
    options = [ "X-mount.subdir=new-root" ];
  };
  fileSystems."/nix" = {
    device = "/dev/vda1";
    fsType = "ext4";
    options = [ "X-mount.subdir=nix" ];
  };

  boot.loader.grub.device = "/dev/vda";
  boot.initrd.systemd.enable = true; # Required for X-mount.subdir

  boot.tmp.cleanOnBoot = true;

  # Networking
  networking = {
    useNetworkd = true;
    usePredictableInterfaceNames = true;
    hostName = "DMIT-zjb93ghp7r";
    domain = "";
  };
  systemd.network = {
    enable = true;
    networks."40-wan" = {
      matchConfig.Name = "en*";
      dns = [
        "2620:fe::fe"
        "9.9.9.9"
      ];
      DHCP = "yes";
    };
  };

  # SSH
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings.PasswordAuthentication = false;
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe"
  ];
}
