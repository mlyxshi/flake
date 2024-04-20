{ config, pkgs, lib, self, ... }: {

  programs.ssh = {
    extraConfig = ''
      Host tmp-install
        HostName tmp-install.mlyxshi.com
        User root
        ProxyCommand ${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h
        StrictHostKeyChecking no
        IdentityFile /secret/ssh/github
    '';
  };

}
