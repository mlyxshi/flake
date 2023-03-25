{
  # https://github.com/mozilla/policy-templates/
  # https://github.com/1sixth/flakes/blob/master/nixos/toy/home/browser.nix
  policies = {

    PasswordManagerEnabled = false;
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    DisableFeedbackCommands = true;
    DisablePocket = true;
    CaptivePortal = false;

    NoDefaultBookmarks = true;
    DontCheckDefaultBrowser = true;

    DisplayBookmarksToolbar = "always";
    Homepage.StartPage = "previous-session";
    OverrideFirstRunPage = "";
    OverridePostUpdatePage = "";

    FirefoxHome = {
      SponsoredTopSites = false;
      Highlights = false;
      Pocket = false;
      SponsoredPocket = false;
      Snippets = false;
    };

    # about:config
    # https://github.com/arkenfox/user.js/blob/master/user.js
    Preferences = {
      #Force Dark theme
      "browser.theme.toolbar-theme" = 0;
      "browser.theme.content-theme" = 0;

      "browser.uidensity" = 1;

      "browser.newtabpage.activity-stream.default.sites" = "";

      "browser.aboutConfig.showWarning" = false;
      "browser.aboutwelcome.enabled" = false;
      "browser.warnOnQuitShortcut" = false;
      "browser.urlbar.dnsResolveSingleWordsAfterSearch" = 0;

      # disable recommended plugin on about:addons
      "extensions.getAddons.showPane" = false;
      "extensions.htmlaboutaddons.recommendations.enabled" = false;

      # Enable CustomCSS
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    };

    # https://github.com/mozilla/policy-templates#extensionsettings
    ExtensionSettings = {
      # PT Plugin Plus
      "{e9c422a1-5740-4c0a-a10e-867939119613}" = {
        installation_mode = "normal_installed";
        install_url = "https://github.com/pt-plugins/PT-Plugin-Plus/releases/download/v1.6.1.2050/PT-Plugin-Plus-1.6.1.2050.xpi";
      };

      # Uninstall unused build-in search shortcuts
      "ebay@search.mozilla.org" = {
        installation_mode = "blocked";
      };

      "amazondotcom@search.mozilla.org" = {
        installation_mode = "blocked";
      };

      "bing@search.mozilla.org" = {
        installation_mode = "blocked";
      };

      "ddg@search.mozilla.org" = {
        installation_mode = "blocked";
      };

      "wikipedia@search.mozilla.org" = {
        installation_mode = "blocked";
      };

    };

    # rm "~/Library/Application Support/Firefox/default/search.json.mozlz4" (macOS) or ~/.mozilla/firefox/*.default/search.json.mozlz4 (Linux) to clean cache
    SearchEngines = {
      Add = [
        {
          Name = "GitHub";
          URLTemplate = "https://github.com/search?q={searchTerms}&type=repositories";
          IconURL = "https://github.com/favicon.ico";
          Alias = "gh";
        }
        {
          Name = "YouTube";
          URLTemplate = "https://www.youtube.com/results?search_query={searchTerms}";
          IconURL = "https://www.youtube.com/favicon.ico";
          Alias = "ytb";
        }
        {
          Name = "Bilibili";
          URLTemplate = "https://search.bilibili.com/all?keyword={searchTerms}";
          IconURL = "https://www.bilibili.com/favicon.ico";
          Alias = "bili";
        }
        {
          Name = "Nix";
          URLTemplate = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
          IconURL = "https://nixos.org/favicon.ico";
          Alias = "nix";
        }
        {
          Name = "GPT";
          URLTemplate = "https://www.bing.com/search?showconv=1&sendquery=1&q={searchTerms}";
          SuggestURLTemplate = "https://api.bing.com/osjson.aspx?query={searchTerms}";
          IconURL = "https://www.bing.com/favicon.ico";
          Alias = "gpt";
        }
      ];
    };

  };
}
