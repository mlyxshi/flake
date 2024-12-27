{ pkgs, lib, config, ... }: {

  imports = [
    ./default.nix
  ];

  networking.hostName = "M4";

  # ssh-ng://root@192.168.1.190 aarch64-linux /Users/dominic/.ssh/id_ed25519 8 1 big-parallel,kvm,nixos-test - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUVJKzd0Y3RDZTJOR3BYdWZNem9MWG5GeThpOGpFVkgzdEdWRmpMY2NOU0YK
  nix.distributedBuilds = true;
  nix.buildMachines = [{
    protocol = "ssh-ng";
    sshUser = "root";
    hostName = "192.168.1.190";
    system = "aarch64-linux";
    sshKey = "/Users/dominic/.ssh/id_ed25519";
    maxJobs = 8;
    supportedFeatures = [
      "big-parallel"
      "kvm"
      "nixos-test"
    ];
    publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUVJKzd0Y3RDZTJOR3BYdWZNem9MWG5GeThpOGpFVkgzdEdWRmpMY2NOU0YK";
  }];
  nix.settings.builders-use-substitutes = true;

  programs.ssh.extraConfig = ''
    Host kexec
      HostName localhost
      HostKeyAlias kexec
      Port 8022
      User root
  '';

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
