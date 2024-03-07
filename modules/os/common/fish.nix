{
  config,
  pkgs,
  lib,
  nixpkgs,
  ...
}:
{

  programs.fish = {
    enable = true;
    shellAliases =
      {
        l = "eza -algh";
        r = "joshuto";
        g = "lazygit";
        c = "bat";
        man = "batman";
        P = "echo $PATH";
        nixpkgs = "hx ${nixpkgs}";
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        sshr = "ssh-keygen -R";
        # Oracle cloud console connection do not support latest openssh(>9.0)
        ssh-old = "nix-shell -p openssh -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/2cdd608fab0af07647da29634627a42852a8c97f.tar.gz";
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        sall = "systemctl list-units";
        slist = "systemctl list-units --type=service";
        stimer = "systemctl list-timers";
        sstat = "systemctl status";
        scat = "systemctl cat";
        slog = "journalctl -u";
        ip = "ip --color=auto";
      };

    shellInit =
      ''
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

        # TokyoNight Color Palette
        set -l foreground c0caf5
        set -l selection 364a82
        set -l comment 565f89
        set -l red f7768e
        set -l orange ff9e64
        set -l yellow e0af68
        set -l green 9ece6a
        set -l purple 9d7cd8
        set -l cyan 7dcfff
        set -l pink bb9af7

        # Syntax Highlighting Colors
        set -g fish_color_normal $foreground
        set -g fish_color_command $cyan
        set -g fish_color_keyword $pink
        set -g fish_color_quote $yellow
        set -g fish_color_redirection $foreground
        set -g fish_color_end $orange
        set -g fish_color_error $red
        set -g fish_color_param $purple
        set -g fish_color_comment $comment
        set -g fish_color_selection --background=$selection
        set -g fish_color_search_match --background=$selection
        set -g fish_color_operator $green
        set -g fish_color_escape $pink
        set -g fish_color_autosuggestion $comment

        # Completion Pager Colors
        set -g fish_pager_color_progress $comment
        set -g fish_pager_color_prefix $cyan
        set -g fish_pager_color_completion $foreground
        set -g fish_pager_color_description $comment
        set -g fish_pager_color_selected_background --background=$selection

      ''
      + lib.optionalString pkgs.stdenv.isDarwin ''
        set -gx EDITOR hx
        set -gx PAGER bat
          
        set PATH $PATH /opt/homebrew/bin ~/go/bin /Applications/Surge.app/Contents/Applications
      '';

    promptInit = ''
      eval (starship init fish)
    '';
  };
}
