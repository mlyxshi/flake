{ pkgs, lib, config, ... }: {

  imports = [
    ./default.nix
  ];

  networking.hostName = "M4";

  nix.distributedBuilds = true;
  nix.buildMachines = [{
    protocol = "ssh-ng";
    hostName = "m1";
    system = "aarch64-linux";
    sshKey = "/Users/dominic/.ssh/id_ed25519"; # default nix builder is _nixbld{} so default sshkey is NOT ~/.ssh/id_ed25519
    maxJobs = 8;
    supportedFeatures = [
      "big-parallel"
      "kvm"
      "nixos-test"
    ];
  }];
  nix.settings.builders-use-substitutes = true;

  programs.ssh.knownHosts.m1.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEI+7tctCe2NGpXufMzoLXnFy8i8jEVH3tGVFjLccNSF";
  programs.ssh.extraConfig = ''
    Host m1
      HostName 192.168.1.190
      HostKeyAlias m1
      User root

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
