# https://nixos.org/manual/nixpkgs/stable/#build-wrapped-firefox-with-extensions-and-policies
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/firefox/wrapper.nix
# https://nixos.wiki/wiki/Firefox
# https://github.com/nix-community/home-manager/blob/master/modules/programs/firefox.nix#blob-path
# https://github.com/mozilla/policy-templates#enterprisepoliciesenabled
# https://github.com/xiaoxiaoflood/firefox-scripts/tree/master/installation-folder
# https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig
let
  metaData = builtins.fromJSON (builtins.readFile ../../config/firefox/version.json);
in
  final: prev: {
    ################################################################################################
    # Linux nightly bin

    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/firefox-bin/default.nix
    firefox-nightly-bin-unwrapped =
      (prev.firefox-bin-unwrapped.override {
        generated.version = metaData.version; # Important, only overrideAttrs version is not enough  <--overide from args
      })
      .overrideAttrs (old: {
        pname = "firefox-bin-unwrapped";
        # version is from generated.version
        src = prev.fetchurl {
          inherit (metaData.linux) url;
          inherit (metaData.linux) sha256;
        };
      });

    firefox-nightly-bin =
      (prev.wrapFirefox final.firefox-nightly-bin-unwrapped {
        forceWayland = true;
        extraPolicies = import ../../config/firefox/app/policy.nix;
        extraPrefs = builtins.readFile ../../config/firefox/app/config.js;
      })
      .overrideAttrs
      (old: {
        # libName = "firefox-bin-${version}";
        buildCommand =
          old.buildCommand
          + ''
            echo 'pref("general.config.sandbox_enabled", false);' >> "$out/lib/firefox-bin-${metaData.version}/defaults/pref/autoconfig.js"
          '';
      });

    ################################################################################################
    # Darwin bin
    firefox-bin-darwin = prev.callPackage ../../pkgs/darwin/Firefox {};
  }
