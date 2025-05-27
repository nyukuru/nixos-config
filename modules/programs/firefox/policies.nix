{pkgs, ...}: {
  nyu.programs.firefox.policies = {
    AppAutoUpdate = false;
    DontCheckDefaultBrowser = true;

    OverrideFirstRunPage = "";
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    DisableFirefoxAccounts = true;
    DisablePocket = true;
    DisableSetDesktopBackground = true;
    DisableFormHistory = true;
    PromptForDownloadLocation = true;

    EnableTrackingProtection = {
      Cryptomining = true;
      Fingerprinting = true;
      Locked = true;
      Value = true;
    };

    ExtensionUpdate = false;

    FirefoxHome = {
      Search = true;
      Pocket = false;
      Snippets = false;
      TopSites = false;
      Highlights = false;
    };

    Cookies = {
      Behavior = "accept";
      Locked = false;
    };

    SecurityDevices = {
      "PKCS#11 Proxy Module" = "${pkgs.p11-kit}/lib/p11-kit-proxy.so";
    };

    NoDefaultBookmarks = true;
    OfferToSaveLogins = false;
    PasswordManagerEnabled = false;
    DisplayBookmarksToolbar = false;
    TranslateEnabled = true;
    ShowHomeButton = false;

    UserMessaging = {
      ExtensionRecommendations = false;
      SkipOnboarding = true;
      MoreFromMozilla = false;
    };
  };
}
