{ config, pkgs, lib, ... }: {

  programs.fish = {
    enable = true;
    shellAliases = {
      l = "eza -algh";
      r = "yazi";
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
}
