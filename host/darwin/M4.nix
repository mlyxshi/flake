{ pkgs, lib, config, ... }: {

  imports = [
    ./default.nix
  ];

  networking.hostName = "M4";

  # remote builder 
  nix.settings.builders = lib.mkForce "ssh-ng://m1 aarch64-linux /Users/dominic/.ssh/id_ed25519 8 1 big-parallel,kvm,nixos-test - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUVJKzd0Y3RDZTJOR3BYdWZNem9MWG5GeThpOGpFVkgzdEdWRmpMY2NOU0YK";
  nix.settings.builders-use-substitutes = true;

  homebrew = {

    brews = [
      "qemu"
      "smartmontools"
    ];

    casks = [
      "android-platform-tools"
      "imazing"
      "drivedx"
      "crystalfetch"
      "utm"
    ];
  };
}