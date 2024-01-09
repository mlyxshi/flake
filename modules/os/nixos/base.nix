{ config, pkgs, lib, nixpkgs, sops-nix, self, ... }: {

  imports = [
    self.nixosModules.os.common
    self.nixosModules.strip
  ];

  sops.defaultSopsFile = ../../../key.yaml;
  sops.age.sshKeyPaths = [ "/persist/sops/key" ];
  sops.gnupg.sshKeyPaths = [ ];

  system.stateVersion = "23.11";

  nix = {
    package = pkgs.nixVersions.unstable;
    channel.enable = false;
    registry.nixpkgs.flake = nixpkgs;
    settings = {
      experimental-features = [ "nix-command" "flakes" "cgroups" "auto-allocate-uids" ];
      # substituters = [ "https://cache.mlyxshi.com" ];
      # trusted-public-keys = [ "cache:vXjiuWtSTOXj63zr+ZjMvXqvaYIK1atjyyEk+iuIqSg=" ];
      auto-optimise-store = true;
      fallback = true;
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
  };

  nixpkgs.config.allowUnfree = true;

  users.users.root = {
    hashedPassword = "$6$fwJZwHNLE640VkQd$SrYMjayP9fofIncuz3ehVLpfwGlpUj0NFZSssSy8GcIXIbDKI4JnrgfMZxSw5vxPkXkAEL/ktm3UZOyPMzA.p0";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe" ];
    shell = pkgs.fish;
  };

  services.openssh = {
    enable = true;
    hostKeys = [{
      path = "/persist/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }];
    settings.PasswordAuthentication = false;
  };

  time.timeZone = "Asia/Tokyo";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.sessionVariables = {
    EDITOR = "hx";
    PAGER = "bat";
    NIX_REMOTE = "daemon"; # root user do not use nix-daemon by default when build. This force nix-daemon to be used. Nix 2.12 cgroups and auto-allocate-uids
  };

  programs.command-not-found.enable = false;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # https://wiki.archlinux.org/title/sysctl
  # https://www.starduster.me/2020/03/02/linux-network-tuning-kernel-parameter/
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3; # tcp fastopen

    # 1000mbps bandwidth: socket receive/send buffer size 16 MB
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
  };

  system.activationScripts."diff-closures".text = ''
    [[ -e "/run/current-system" ]] && ${pkgs.nix}/bin/nix store  diff-closures /run/current-system $systemConfig
  '';

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "update" ''
      [[ -e "/persist/flake/flake.nix" ]] || git clone --depth=1  git@github.com:mlyxshi/flake /persist/flake
      
      cd /persist/flake
      git pull 

      # bash -c '[[ $- == *i* ]] && echo Interactive || echo not-interactive
      [[ $- == *i* ]] && NIX=nom || NIX=nix 
      HOST=''${1:-$(hostnamectl hostname)} 
      
      SYSTEM=$($NIX build --no-link --print-out-paths .#nixosConfigurations.$HOST.config.system.build.toplevel)
      
      if [ -n "$SYSTEM" ]
      then
        sudo nix-env -p /nix/var/nix/profiles/system --set $SYSTEM
        sudo $SYSTEM/bin/switch-to-configuration switch
      else
        echo "Build Failed"
        exit 1
      fi
    '')

    (pkgs.writeShellScriptBin "local-update" ''
      cd /persist/flake
      
      SYSTEM=$(nom build --no-link --print-out-paths .#nixosConfigurations.$(hostnamectl hostname).config.system.build.toplevel)
      
      if [ -n "$SYSTEM" ]
      then
        sudo nix-env -p /nix/var/nix/profiles/system --set $SYSTEM
        sudo $SYSTEM/bin/switch-to-configuration switch
      else
        echo "Build Failed"
        exit 1
      fi
    '')

    (pkgs.writeShellScriptBin "config-update" ''
      [[ -e "/persist/flake/flake.nix" ]] || git clone --depth=1  git@github.com:mlyxshi/flake /persist/flake
      
      cd /persist/flake
      git pull 
      
      chmod +x ./config.sh
      ./config.sh
    '')
  ];

  # https://github.com/numtide/srvos/blob/main/nixos/common/networking.nix
  systemd.services.systemd-networkd.stopIfChanged = false;
  systemd.services.systemd-resolved.stopIfChanged = false;
}
