# https://nixos.org/manual/nixpkgs/stable/#build-wrapped-firefox-with-extensions-and-policies
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/firefox/wrapper.nix
# https://nixos.wiki/wiki/Firefox
# https://github.com/nix-community/home-manager/blob/master/modules/programs/firefox.nix#blob-path
# https://github.com/mozilla/policy-templates#enterprisepoliciesenabled
# https://github.com/xiaoxiaoflood/firefox-scripts/tree/master/installation-folder
# https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig
final: prev: {
  ################################################################################################
  # Linux
  firefox = prev.wrapFirefox prev.firefox-unwrapped {
    extraPolicies = import ../../config/firefox/app/policy.nix;
  };

  # Darwin
  firefox-bin-darwin = prev.callPackage ../../pkgs/darwin/Firefox { };
}
