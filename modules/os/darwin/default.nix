{ pkgs, lib, config, nixpkgs, ... }: {

  imports = [
    ../common

    ./systemDefaults.nix
    ./launchd.nix
    ./brew.nix
  ];

  nix = {
    package = pkgs.nixUnstable;
    registry.nixpkgs.flake = nixpkgs;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "dominic" ];
    };
    gc = {
      automatic = true;
      # interval is darwin launchd syntax
      interval = { Hour = 24; };
      options = "--delete-older-than 7d";
    };
  };

  services.nix-daemon.enable = true;

  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowBroken = true;

  # change default shell to fish
  # sudo bash -c 'echo "/run/current-system/sw/bin/fish" >> /etc/shells' 
  # chsh -s /run/current-system/sw/bin/fish dominic

  programs.ssh = {
    knownHosts = {
      github = {
        hostNames = [ "github.com" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
    };
  };


  # environment.etc."firefox/policies/policies.json".text = builtins.toJSON (import ../../config/firefox/policy.nix);
  # it seems that firefox do not support system level /etc/firefox/policies/policies.json on MacOS, create in application directory manually
  system.activationScripts.postActivation.text = '' 
    [[ -e "/run/current-system" ]] && ${pkgs.nix}/bin/nix store  diff-closures /run/current-system "$systemConfig"

    [[ -e "/Applications/Firefox.app/Contents/Resources/" ]] && mkdir -p /Applications/Firefox.app/Contents/Resources/distribution && cat ${pkgs.writeText "firefoxPolicy" (builtins.toJSON (import ../../../config/firefox/policy.nix))} > /Applications/Firefox.app/Contents/Resources/distribution/policies.json
  '';


  # Add MITM CA for debug network
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
