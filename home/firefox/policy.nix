{
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

      "browser.newtabpage.activity-stream.logowordmark.alwaysVisible" = false;
      "browser.newtabpage.activity-stream.topSitesRows" = 1;
      "browser.newtabpage.pinned" = ''
        [{"url":"https://github.com/mlyxshi/flake","label":"flake"},{"url":"https://www.youtube.com/","label":"youtube"},{"url":"https://music.youtube.com/","label":"music"},{"url":"http://www.bilibili.com/","label":"bilibili"},{"url":"https://twitter.com","label":"twitter"},{"url":"https://old.reddit.com/","label":"reddit"},{"url":"https://bgm.tv/group","label":"bgm"},{"url":"https://neodb.social/discover/","label":"neodb"}]'';

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
  };
}
