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

  nativeMessagingHostsJoined = pkgs.symlinkJoin {
    name = "home_ff_nmhs";
    paths = [
      pkgs.ff2mpv
    ];
  };


in
{
  programs.firefox.enable = true;
  programs.firefox.package = null;


  home.file = {
    "${NativeMessagingHostsPath}".source =
      "${nativeMessagingHostsJoined}/lib/mozilla/native-messaging-hosts";
  };

  programs.firefox.profiles."default" = {
    userChrome = ''  
      #import-button, #fxa-toolbar-menu-button, #appMenu-passwords-button {
        display: none !important;
      }
    '';

    search = {
      force = true;
      engines = {
        "Nix" = {
          urls = [{ template = "https://search.nixos.org/options?type=options&query={searchTerms}"; }];
          iconURL = "https://nixos.org/favicon.ico";
          definedAliases = [ "@nix" ];
        };

        "GitHub" = {
          urls = [{ template = "https://github.com/search?q=NOT+is%3Afork+{searchTerms}&type=code"; }];
          iconURL = "https://github.com/favicon.ico";
          definedAliases = [ "@gh" ];
        };

        "YouTube" = {
          urls = [{ template = "https://www.youtube.com/results?search_query={searchTerms}"; }];
          iconURL = "https://www.youtube.com/favicon.ico";
          definedAliases = [ "@ytb" ];
        };

        "Bilibili" = {
          urls = [{ template = "https://search.bilibili.com/all?keyword={searchTerms}"; }];
          iconURL = "https://www.bilibili.com/favicon.ico";
          definedAliases = [ "@bili" ];
        };

        "GPT" = {
          urls = [{ template = "https://www.bing.com/search?showconv=1&sendquery=1&q={searchTerms}"; }];
          iconURL = "https://www.bing.com/favicon.ico";
          definedAliases = [ "@gpt" ];
        };

        # disable default search engines
        "Amazon.com".metaData.hidden = true;
        # "Bing".metaData.hidden = true;
        "DuckDuckGo".metaData.hidden = true;
        "eBay".metaData.hidden = true;
        "Wikipedia (en)".metaData.hidden = true;
      };
    };
  };
}
