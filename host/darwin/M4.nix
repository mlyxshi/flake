{
  ...
}:
{

  imports = [
    ./default.nix
  ];

  networking.hostName = "M4";

  programs.ssh.knownHosts.m1.publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEI+7tctCe2NGpXufMzoLXnFy8i8jEVH3tGVFjLccNSF";
  programs.ssh.extraConfig = ''
    Host m1
      HostName 192.168.1.190
      HostKeyAlias m1
      User root
  '';

  homebrew = {

    brews = [
      "smartmontools"
    ];

    casks = [
      "imazing"
      "drivedx"
    ];
  };
}
