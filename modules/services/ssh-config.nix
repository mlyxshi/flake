{ pkgs, lib, config, ... }: {
  age.secrets.github-private-key.file = ../../secrets/github-private-key.age;
  # ssh (client)
  programs.ssh = {
    knownHosts = {
      "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };

    extraConfig = ''
      Host github.com
        User git
        IdentityFile ${config.age.secrets.github-private-key.path}
    '';
  };

}
