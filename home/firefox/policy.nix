{
  # https://github.com/mozilla/policy-templates/

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

    # Proxy = {
    #   Mode = "manual";
    #   SOCKSProxy = "127.0.0.1:1080";
    #   SOCKSVersion = 5;
    #   UseProxyForDNS = true;
    # };

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
      # Force Dark theme
      "browser.theme.toolbar-theme" = 0;
      "browser.theme.content-theme" = 0;

      "browser.uidensity" = 1;

      "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = "";

      "browser.newtabpage.activity-stream.topSitesRows" = 2;
      "browser.newtabpage.pinned" = ''[{"url":"https://github.com/mlyxshi/flake","label":"flake","baseDomain":"github.com"},{"url":"https://github.com/mlyxshi?tab=stars","label":"star","baseDomain":"github.com"},{"url":"http://top.mlyxshi.com/","label":"top","baseDomain":"top.mlyxshi.com"},{"url":"https://www.youtube.com/","label":"youtube","baseDomain":"youtube.com"},{"url":"https://music.youtube.com/","label":"Music","baseDomain":"music.youtube.com"},{"url":"http://www.bilibili.com/","label":"bilibili","baseDomain":"bilibili.com"},{"url":"https://old.reddit.com/","label":"Reddit"}]'';
      "browser.newtabpage.activity-stream.feeds.section.highlights" = true;
      "browser.newtabpage.activity-stream.section.highlights.rows" = 2;

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
    # ExtensionSettings = {
    #   # PT Plugin Plus
    #   "{e9c422a1-5740-4c0a-a10e-867939119613}" = {
    #     installation_mode = "normal_installed";
    #     install_url = "https://github.com/pt-plugins/PT-Plugin-Plus/suites/13704627945/artifacts/757780101";
    #   };
    # };

  };
}
