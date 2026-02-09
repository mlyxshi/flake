{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{

  imports = [
    self.nixosModules.strip.default
  ];

  security.sudo.enable = false;

  system.stateVersion = lib.trivial.release;
  system.nixos-init.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.latest;
    channel.enable = false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "cgroups"
        "auto-allocate-uids"
      ];
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

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe"
    ];
    # shell = pkgs.fish;
  };

  services.dbus.implementation = "broker";

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings.PasswordAuthentication = false;
  };

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/keys
  # This is convenient for immutable /etc. I use it at my own risk.
  environment.etc = {
    "ssh/ssh_host_ed25519_key.pub" = {
      text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBWcxb/Blaqt1auOtE+F8QUWrUotiC5qBJ+UuEWdVCb";
      mode = "0400";
    };
    "ssh/ssh_host_ed25519_key" = {
      text = ''
        -----BEGIN OPENSSH PRIVATE KEY-----
        b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
        QyNTUxOQAAACCQVnMW/wZWqrdWrjrRPhfEFFq1KLYguagSflLhFnVQmwAAAJASuMMnErjD
        JwAAAAtzc2gtZWQyNTUxOQAAACCQVnMW/wZWqrdWrjrRPhfEFFq1KLYguagSflLhFnVQmw
        AAAEDIN2VWFyggtoSPXcAFy8dtG1uAig8sCuyE21eMDt2GgJBWcxb/Blaqt1auOtE+F8QU
        WrUotiC5qBJ+UuEWdVCbAAAACnJvb3RAbml4b3MBAgM=
        -----END OPENSSH PRIVATE KEY-----
      '';
      mode = "0400";
    };
    "machine-id".text = "f94755ad039f4e96a1796d58cbef4c73"; # make systemd happy
  };

  programs.ssh.knownHosts."github.com".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

  environment.sessionVariables = {
    EDITOR = "hx";
    PAGER = "bat";
    NIX_REMOTE = "daemon"; # root user do not use nix-daemon by default when build. This force nix-daemon to be used. Nix 2.12 cgroups and auto-allocate-uids
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [
    wget
    dig
    file
    htop
    libarchive
    nix-output-monitor
    nix-tree
    yazi-unwrapped
    helix
    fd
    ripgrep
    starship
    zoxide
    eza
    bat
    bat-extras.batman
    gdu
    gptfdisk
    gitMinimal

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
      nt = "nexttrace";

      sall = "systemctl list-units";
      slist = "systemctl list-units --type=service";
      stimer = "systemctl list-timers";
      sstat = "systemctl status";
      scat = "systemctl cat";
      slog = "journalctl -u";

      nds = "nix derivation show";
    };

    shellInit = ''
      set -U fish_greeting
      zoxide init fish | source

      function loc
        readlink -f $(which $argv) 
      end

      function nids
        nix derivation show $(nix-instantiate -A $argv)
      end
    '';

    promptInit = ''
      eval (starship init fish)
    '';
  };
}
