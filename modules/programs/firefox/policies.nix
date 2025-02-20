{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib.options)
    mkOption
    ;

  inherit
    (lib.attrsets)
    concatMapAttrs
    ;

  mkExtensions = extensions:
    concatMapAttrs (
      _: extension: {
        ${extension.addonID} = {
          install_url = extension.installUrl;
          installation_mode = extension.installMode;
          default_area = "menupanel";
        };
      }
    )
    extensions;

  json = pkgs.formats.json {};
  cfg = config.modules.programs.firefox;
in {
  options.modules.programs.firefox = {
    policies = mkOption {
      type = json.type;
      default = {};
      description = "Mozilla policies.";
    };
  };

  config.modules.programs.firefox.policies = {
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

    ExtensionSettings = mkExtensions cfg.extensions // {"*".installation_mode = "blocked";};
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
