{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.strip
  ];

  security.sudo.enable = false;

  system.stateVersion = "25.05";

  nix = {
    package = pkgs.nixVersions.latest;
    channel.enable = false;
    settings = {
      experimental-features = [ "nix-command" "flakes" "cgroups" "auto-allocate-uids" ];
      # substituters = [ "https://mlyxshi.cachix.org" ];
      # trusted-public-keys = [ "mlyxshi.cachix.org-1:BVd+/1A5uLMI8pTUdhdh6sdefTRdj+/PVgrUh9L2hWw=" ];
      log-lines = 25;
      # experimental
      use-cgroups = true;
      auto-allocate-uids = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
  };

  nixpkgs.config.allowUnfree = true;

  users.users.root = {
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe" ];
    shell = pkgs.fish;
  };

  services.openssh = {
    enable = true;
    hostKeys = [{
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }];
    settings.PasswordAuthentication = false;
  };

  programs.ssh.knownHosts."github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.sessionVariables = {
    EDITOR = "hx";
    PAGER = "bat";
    NIX_REMOTE = "daemon"; # root user do not use nix-daemon by default when build. This force nix-daemon to be used. Nix 2.12 cgroups and auto-allocate-uids
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # https://wiki.archlinux.org/title/sysctl
  boot.kernel.sysctl = {
    # 1000mbps bandwidth: socket receive/send buffer size 16 MB for hysteria2
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
  };


  environment.systemPackages = with pkgs;[
    wget
    dig
    file
    htop
    iperf
    tree
    libarchive
    nix-output-monitor
    nix-tree
    nix-inspect
    nixpkgs-fmt
    yazi
    helix
    nil
    fd
    ripgrep
    starship
    zoxide
    atuin
    eza
    xh
    tealdeer
    bandwhich
    bat
    bat-extras.batman
    gdu
    gitMinimal
    gptfdisk

    (writeShellScriptBin "update" ''
      if [[ -e "/flake/flake.nix" ]]
      then
        cd /flake
        git pull   
      else
        git clone --depth=1  git@github.com:mlyxshi/flake /flake
        cd /flake
      fi  


      # bash -c '[[ $- == *i* ]] && echo Interactive || echo not-interactive
      [[ $- == *i* ]] && NIX=nom || NIX=nix 
      HOST=''${1:-$(hostnamectl hostname)} 

      SYSTEM=$($NIX build --no-link --print-out-paths .#nixosConfigurations.$HOST.config.system.build.toplevel)

      if [ -n "$SYSTEM" ]
      then
        [[ -e "/run/current-system" ]] && nix store diff-closures /run/current-system $SYSTEM
        nix-env -p /nix/var/nix/profiles/system --set $SYSTEM
        $SYSTEM/bin/switch-to-configuration switch
      else
        echo "Build Failed"
        exit 1
      fi
    '')

    (writeShellScriptBin "local-update" ''
      cd /flake

      SYSTEM=$(nom build --no-link --print-out-paths .#nixosConfigurations.$(hostnamectl hostname).config.system.build.toplevel)

      if [ -n "$SYSTEM" ]
      then
        nix-env -p /nix/var/nix/profiles/system --set $SYSTEM
        $SYSTEM/bin/switch-to-configuration switch
      else
        echo "Build Failed"
        exit 1
      fi
    '')
  ];


  programs.fish = {
    enable = true;
    shellAliases = {
      l = "eza -algh";
      r = "yazi";
      g = "lazygit";
      c = "bat";
      man = "batman";
      P = "echo $PATH";

      sall = "systemctl list-units";
      slist = "systemctl list-units --type=service";
      stimer = "systemctl list-timers";
      sstat = "systemctl status";
      scat = "systemctl cat";
      slog = "journalctl -u";
      nixpkgs = "hx ${config.nixpkgs.flake.source}";
    };

    shellInit = ''
      set -U fish_greeting
      zoxide init fish | source
      atuin init fish --disable-up-arrow | source

      function loc
        readlink -f $(which $argv) 
      end

      function cnar
        curl https://cache.mlyxshi.com/$argv.narinfo  
      end

      function drv
        nix show-derivation $(nix-store -q --deriver $argv)
      end

      # immediate reference(1 level)
      function ref
        nix-store -q --references $(readlink -f $(which $argv))
      end

      # recursive reference (All level)
      function closure 
        nix-store -q --requisites $(readlink -f $(which $argv))
      end

      function ref-re
        nix-store -q --referrers $(readlink -f $(which $argv))
      end

      function closure-re
        nix-store -q --referrers-closure $(readlink -f $(which $argv))
      end
    '';

    promptInit = ''
      eval (starship init fish)
    '';
  };
}
