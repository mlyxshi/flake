{ pkgs, lib, config, osConfig, ... }:
let
  zsh-config = ../config/zsh;
in
{
  home.packages = with pkgs; [
    fzf
    zsh-fzf-tab
  ];

  programs.zoxide.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      gcloud.disabled = true;
    };
  };

  programs.nix-index.enable = osConfig.settings.developerMode;

  programs.direnv = lib.optionalAttrs osConfig.settings.developerMode {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;

    # under linux, use environment.sessionVariables to set env <-- headless mode and desktop mode
    # under darwin, use zsh module  <-- only desktop mode

    shellAliases =
      {
        cd = "z";
        l = "exa -algh";
        v = "nvim";
        r = "lf";
        p = "procs";
        g = "lazygit";
        c = "bat";
        man = "batman";
        P = ''echo $PATH|sed "s/:/\n/g"'';
        loc = "_f(){readlink -f $(which $1)};_f";
        pb = "_f(){curl -Fc=@$1 https://pb.mlyxshi.com};_f";
        cnar = "_f(){curl https://cache.mlyxshi.com/$1.narinfo};_f";

        drv = "_f(){nix show-derivation $(nix-store -q --deriver $1)};_f";
        ref = "_f(){nix-store -q --references $(readlink -f $(which $1))};_f"; # ref: immediate reference(1 level)
        closure = "_f(){nix-store -q --requisites $(readlink -f $(which $1))};_f"; # clousure: recursive reference (All level)

        ref-re = "_f(){nix-store -q --referrers $(readlink -f $(which $1))};_f";
        closure-re = "_f(){nix-store -q --referrers-closure $(readlink -f $(which $1))};_f";
        # Oracle cloud console connection do not support latest openssh(>9.0)
        ssh-old = "nix-shell -p openssh -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/2cdd608fab0af07647da29634627a42852a8c97f.tar.gz";
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        update = "cd ~/flake; git add .; darwin-rebuild switch --flake ~/flake#M1";
        rclonemount = "${pkgs.rclone}/bin/rclone mount googleshare:Download /Users/dominic/rcloneMount &";
        sshr = "ssh-keygen -R";
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        slist = "systemctl list-units --all --type=service";
        stimer = "systemctl list-timers";
        sstat = "systemctl status";
        scat = "systemctl cat";
        slog = "journalctl -u";
        ip = "ip --color=auto";
      };

    initExtra = ''

        setopt globdots

        export FZF_COMPLETION_TRIGGER='\'

        # exa default LS_COLORS: https://github.com/ogham/exa/issues/544
        export LS_COLORS="di=1;34:ln=0;36:pi=0;33:bd=1;33:cd=1;33:so=1;31:ex=1;32:*README=1;4;33:*README.txt=1;4;33:*README.md=1;4;33:*readme.txt=1;4;33:*readme.md=1;4;33:*.ninja=1;4;33:*Makefile=1;4;33:*Cargo.toml=1;4;33:*SConstruct=1;4;33:*CMakeLists.txt=1;4;33:*build.gradle=1;4;33:*pom.xml=1;4;33:*Rakefile=1;4;33:*package.json=1;4;33:*Gruntfile.js=1;4;33:*Gruntfile.coffee=1;4;33:*BUILD=1;4;33:*BUILD.bazel=1;4;33:*WORKSPACE=1;4;33:*build.xml=1;4;33:*Podfile=1;4;33:*webpack.config.js=1;4;33:*meson.build=1;4;33:*composer.json=1;4;33:*RoboFile.php=1;4;33:*PKGBUILD=1;4;33:*Justfile=1;4;33:*Procfile=1;4;33:*Dockerfile=1;4;33:*Containerfile=1;4;33:*Vagrantfile=1;4;33:*Brewfile=1;4;33:*Gemfile=1;4;33:*Pipfile=1;4;33:*build.sbt=1;4;33:*mix.exs=1;4;33:*bsconfig.json=1;4;33:*tsconfig.json=1;4;33:*.zip=0;31:*.tar=0;31:*.Z=0;31:*.z=0;31:*.gz=0;31:*.bz2=0;31:*.a=0;31:*.ar=0;31:*.7z=0;31:*.iso=0;31:*.dmg=0;31:*.tc=0;31:*.rar=0;31:*.par=0;31:*.tgz=0;31:*.xz=0;31:*.txz=0;31:*.lz=0;31:*.tlz=0;31:*.lzma=0;31:*.deb=0;31:*.rpm=0;31:*.zst=0;31:*.lz4=0;31"

        zstyle -e '*' list-colors 'reply=(''${(s[:])LS_COLORS})'
        zstyle ':completion:*:descriptions' format '[%d]'
        zstyle ':fzf-tab:*' switch-group ',' '.'
        zstyle ':fzf-tab:*' continuous-trigger 'space'

        zstyle ':fzf-tab:complete:z:*' fzf-preview 'if [ -d "$realpath" ]; then exa -1 --color=always "$realpath"; else pistol "$realpath"; fi'
        zstyle ':fzf-tab:complete:z:*' fzf-pad 50

        zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w'
        zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:4:wrap'

        zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

        source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh

        source ${pkgs.fzf}/share/fzf/completion.zsh
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh
        source ${zsh-config}/ssh.zsh
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh

      ''
    + lib.optionalString pkgs.stdenv.isDarwin ''

        export EDITOR=nvim
        export PAGER=bat

        path+=~/go/bin
        path+=/Applications/Surge.app/Contents/Applications
                
        [[ "$TERM" == "xterm-kitty" ]] && alias ssh="kitty +kitten ssh"

      '';
  };
}
