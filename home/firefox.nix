{ pkgs, lib, config, ... }:
let
  FirefoxProfilePath =
    if pkgs.stdenv.isLinux
    then ".mozilla/firefox"
    else "Library/Application Support/Firefox";

  NativeMessagingHostsPath =
    if pkgs.stdenv.isLinux
    then ".mozilla/native-messaging-hosts"
    else "Library/Application Support/Mozilla/NativeMessagingHosts";

  ff-mpv = pkgs.writeScript "ff2mpv" (''
    #!${pkgs.python3}/bin/python
  ''
  + builtins.readFile ../config/firefox/NativeMessagingHosts/ff2mpv.py);
in
{

  #  https://support.mozilla.org/en-US/kb/understanding-depth-profile-installation
  #  Linux firefox wrapper set MOZ_LEGACY_PROFILES=1 by default
  #  Under macOS, we need to set System-level environment variable MOZ_LEGACY_PROFILES=1 by launchctl setenv, See os/darwin/default.nix
  home.file = {
    "${FirefoxProfilePath}/profiles.ini".source = ../config/firefox/profile/profiles.ini; # Do not give write permission
    "${FirefoxProfilePath}/default/chrome".source = ../config/firefox/profile/default/chrome;

    # woodruffw/ff2mpv
    "${NativeMessagingHostsPath}/ff2mpv.json".text = ''
      {
        "name": "ff2mpv",
        "description": "ff2mpv's external manifest",
        "path": "${ff-mpv}",
        "type": "stdio",
        "allowed_extensions": ["ff2mpv@yossarian.net"]
      }
    '';
  };
}
