{ pkgs, lib, config, ... }: {

  networking.hostName = "M4";

  users.users.dominic.home = "/Users/dominic";
  users.users.dominic.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe" ];

  environment.systemPackages = with pkgs; [
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
    joshuto
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
    home-manager
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
      "qemu"
      "smartmontools"
      "cloudflared"
      "yt-dlp"
      "ffmpeg"
      "mediainfo"
      "openjdk"
    ];

    casks = [
      "jordanbaird-ice"
      "vnc-viewer"
      "iina"
      "element"
      "input-source-pro"
      "crystalfetch"
      "font-roboto-mono-nerd-font"
      "maczip"
      "openineditor-lite"
      "openinterminal-lite"
      "raycast"
      "visual-studio-code"
      "transmission"
      "istat-menus"
      "neteasemusic"
      "telegram-desktop"
      "uninstallpkg"
      "suspicious-package"
      "snipaste"
      "google-chrome"
      "android-platform-tools"


      ##############################################
      # "karabiner-elements"
      # "wireshark"
      # "betterdisplay"
      # "utm"
    ];
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "dominic" ];
    };
  };

  system.stateVersion = 5;

  programs.ssh = {
    knownHosts = {
      github = {
        hostNames = [ "github.com" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
    };
  };

  system.activationScripts.postActivation.text = ''
    [[ -e "/run/current-system" ]] && ${pkgs.nix}/bin/nix store  diff-closures /run/current-system "$systemConfig"
  '';

  programs.fish = {
    enable = true;
    shellAliases = {
      l = "eza -algh";
      r = "joshuto";
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

      # catppuccin_macchiato theme
      set -g fish_color_normal cad3f5
      set -g fish_color_command 8aadf4
      set -g fish_color_param f0c6c6
      set -g fish_color_keyword ed8796
      set -g fish_color_quote a6da95
      set -g fish_color_redirection f5bde6
      set -g fish_color_end f5a97f
      set -g fish_color_comment 8087a2
      set -g fish_color_error ed8796
      set -g fish_color_gray 6e738d
      set -g fish_color_selection --background=363a4f
      set -g fish_color_search_match --background=363a4f
      set -g fish_color_option a6da95
      set -g fish_color_operator f5bde6
      set -g fish_color_escape ee99a0
      set -g fish_color_autosuggestion 6e738d
      set -g fish_color_cancel ed8796
      set -g fish_color_cwd eed49f
      set -g fish_color_user 8bd5ca
      set -g fish_color_host 8aadf4
      set -g fish_color_host_remote a6da95
      set -g fish_color_status ed8796
      set -g fish_pager_color_progress 6e738d
      set -g fish_pager_color_prefix f5bde6
      set -g fish_pager_color_completion cad3f5
      set -g fish_pager_color_description 6e738d   
    '' + lib.optionalString pkgs.stdenv.isDarwin ''
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
