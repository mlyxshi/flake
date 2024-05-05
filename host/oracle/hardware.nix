{ modulesPath, pkgs, lib, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.systemd.enable = true;

  boot.initrd.systemd.root = "gpt-auto";
  boot.initrd.supportedFilesystems = [ "ext4" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.timeout = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.services."netbootxyz-init" = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    unitConfig.ConditionPathExists = "!/boot/netboot.xyz-arm64.efi";
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/boot";
      ExecStart = "${pkgs.curl}/bin/curl -LO https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi";
    };
  };
}
