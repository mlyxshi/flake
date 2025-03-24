{ config, pkgs, lib, ... }: {

  environment.systemPackages = with pkgs;[
    (writeShellScriptBin "remote-update" ''
      if [[ -e "/flake/flake.nix" ]]
      then
        cd /flake
        git pull   
      else
        git clone --depth=1  git@github.com:mlyxshi/flake /flake
        cd /flake
      fi  

      HOST=''$1

      SYSTEM=$(nix build --no-link --print-out-paths .#nixosConfigurations.$HOST.config.system.build.toplevel)

      if [ -n "$SYSTEM" ]
      then
        nix copy --to ssh://$HOST $SYSTEM
        ssh $HOST nix-env -p /nix/var/nix/profiles/system --set $SYSTEM
        ssh $HOST $SYSTEM/bin/switch-to-configuration switch
      else
        echo "Build Failed"
        exit 1
      fi
    '')
  ];

  programs.ssh.extraConfig = ''
    Host pvg
      HostName pvg.mlyxshi.com
      User root
      IdentityFile /secret/ssh/github
  '';

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table ip REDIRECT {
      chain PREROUTING {
        type nat hook prerouting priority -100; policy accept;
        tcp dport 1112 dnat to 45.149.92.126:8888 
      }

      chain POSTROUTING {
        type nat hook postrouting priority 100; policy accept;
        ip daddr 45.149.92.126 tcp dport 8888 masquerade
      }
    }
  '';
}
