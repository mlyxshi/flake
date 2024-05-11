{ config, pkgs, lib, ... }: {

  programs.fish = {
    enable = true;
    shellAliases = {
      l = "eza -algh";
      r = "joshuto";
      g = "lazygit";
      c = "bat";
      man = "batman";
      P = "echo $PATH";
    } // lib.optionalAttrs pkgs.stdenv.isDarwin { sshr = "ssh-keygen -R"; }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
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
      
    '' + lib.optionalString pkgs.stdenv.isDarwin ''
      set -gx EDITOR hx
      set -gx PAGER bat
        
      set PATH $PATH /opt/homebrew/bin ~/go/bin /Applications/Surge.app/Contents/Applications
    '';

    promptInit = ''
      eval (starship init fish)
    '';
  };
}
