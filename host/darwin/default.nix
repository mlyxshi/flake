{ pkgs, lib, config, ... }: {

  system.stateVersion = 5;

  users.users.dominic.home = "/Users/dominic";
  users.users.dominic.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe" ];

  nix = {
    channel.enable = false;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "dominic" ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget
    dig
    file
    htop
    iperf
    nexttrace
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
    gh
    jq
    lazygit
    restic
    nix-init
    nix-update
    (pkgs.writeShellScriptBin "update" ''
      cd /Users/dominic/flake
      SYSTEM=$(nix build --no-link --print-out-paths .#darwinConfigurations.${config.networking.hostName}.system)

      if [ -n "$SYSTEM" ]
      then
        sudo -H --preserve-env=PATH env nix-env -p /nix/var/nix/profiles/system --set $SYSTEM
        $SYSTEM/activate-user
        sudo -H --preserve-env=PATH $SYSTEM/activate
      else
        echo "Build Failed"
        exit 1
      fi
    '')
  ];

  system.defaults.dock.autohide = true;
  system.defaults.finder.ShowPathbar = true;
  system.defaults.finder.FXPreferredViewStyle = "Nlsv";
  system.defaults.finder.FXDefaultSearchScope = "SCcf";

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    taps = [
      "homebrew/services"
    ];

    brews = [
      "iproute2mac"
    ];

    casks = [
      "ghostty"
      "visual-studio-code"
      "jordanbaird-ice"
      "input-source-pro"
      "maczip"
      "openineditor-lite"
      "openinterminal-lite"
      "raycast"
      "transmission"
      "istat-menus"
      "uninstallpkg"
      "suspicious-package"
      "google-chrome"
    ];
  };

  programs.ssh.knownHosts."github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  programs.ssh.extraConfig = ''
    Host us
    	HostName  us.mlyxshi.com
      HostKeyAlias us
    	User root

    Host jp1
    	HostName  jp1.mlyxshi.com
      HostKeyAlias jp1
    	User root

    Host jp2
    	HostName  jp2.mlyxshi.com
      HostKeyAlias jp2
    	User root

    Host hk
    	HostName  hk.mlyxshi.com
      HostKeyAlias hk
    	User root
    
    Host ntt
    	HostName  ntt.mlyxshi.com
      HostKeyAlias ntt
    	User root

    Host gh
      User runner
      StrictHostKeyChecking no
      ProxyCommand /opt/homebrew/bin/cloudflared access ssh --hostname github-action-ssh.mlyxshi.com
  '';

  system.activationScripts.postActivation.text = ''
    [[ -e "/run/current-system" ]] && ${pkgs.nix}/bin/nix store  diff-closures /run/current-system "$systemConfig"
  '';

  programs.fish = {
    enable = true;
    shellAliases = {
      l = "eza -algh";
      r = "yazi";
      g = "lazygit";
      c = "bat";
      man = "batman";
      P = "echo $PATH";
      sshr = "ssh-keygen -R";
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

      set -gx EDITOR hx
      set -gx PAGER bat
        
      set PATH $PATH /opt/homebrew/bin ~/go/bin /Applications/Surge.app/Contents/Applications
    '';

    promptInit = ''
      eval (starship init fish)
    '';
  };

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIICtjCCAZ4CCQDpyQH31X0PGDANBgkqhkiG9w0BAQsFADAcMQswCQYDVQQGEwJV
      UzENMAsGA1UEAwwETUlUTTAgFw0yMjAzMjAxMTQwMTlaGA8yMTIyMDIyNDExNDAx
      OVowHDELMAkGA1UEBhMCVVMxDTALBgNVBAMMBE1JVE0wggEiMA0GCSqGSIb3DQEB
      AQUAA4IBDwAwggEKAoIBAQDdeBgprOvAMyHW4qDzQY6vaoYHK8xImXWV+fepNk8j
      NLOb8c38f8pmvMHl/HpR2KYlAbCYpvuKDSEUcu51apIlWS1+jxwN6hlPRxFT0BzZ
      6/A2Gxd6wDko+0FGcILkOWgNnFlrEX5sp2nyXZoPk7Oc53JSoo8SKuRkdSKHqi1Z
      nWhlsqo0lN3sYQldziAXHv/GAZ60HoYH2b1XG5nWF88p/jRMnsdYAtp3/lsKNIFd
      pSWFZDzMQGQQLIVyvSDJmMl/Z9/7pnVE0iB4A55ATeZv9MXtVsjPZlgtu0Hj0QxC
      +gnDlwjPFm3zVGmLUEf57LV5BWd+Hv3TBh3Da3qLsi9hAgMBAAEwDQYJKoZIhvcN
      AQELBQADggEBAKZRgSLvmUXkLJJibD5m8kdDy4g0TJZNu3O4BXZINbaDbQQpDJ0u
      F9Me6s8i+BcQrkNpV+kjeeiJNSOutyB66Ma05js6KaREi+dIIt7/RO1iH5wzLjHS
      po2gvupEeZxi17pF9d/Ui11mv5XC4VOp71/ASuUc/MmyEf29uG9AD9bNWibS/Zq0
      QMWycsQAr4qbXgb7xvJJGMNqcyuvUakfnoYP0TS11FT/BKSPxZ/C555VV2qtW/xy
      BjFGG20IILxSlOC1cBbxRkKt5fTCoO4PUTjLE8/YuLWwG1cRYOmhAVqi4/lZ4vw1
      fvwPUdrh/5WRrBD7Eif4i02yZJjxzbxiW4U=
      -----END CERTIFICATE-----
    ''
  ];
}


# change default shell to fish
# sudo bash -c 'echo "/run/current-system/sw/bin/fish" >> /etc/shells' 
# chsh -s /run/current-system/sw/bin/fish dominic
