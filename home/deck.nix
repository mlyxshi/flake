{ pkgs, lib, config, self, ... }: {

  imports = [
    ./desktop.nix
    ./fish.nix
    ./common-package.nix
  ];

  home = {
    username = "deck";
    homeDirectory = "/home/deck";
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };

  home.packages = with pkgs; [
    qbittorrent
  ];

  home.activation.myScript = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d ~/.ssh ]; then
      mkdir -p ~/.ssh
      echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe" > ~/.ssh/authorized_keys
    fi

    if [ ! -d /etc/firefox/policies ]; then
      /usr/bin/sudo mkdir -p /etc/firefox/policies
      /nix/var/nix/profiles/default/bin/nix eval --json --file /home/deck/flake/home/firefox/policy.nix  | /usr/bin/sudo tee /etc/firefox/policies/policies.json
    fi
  '';
}
