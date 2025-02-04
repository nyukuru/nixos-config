{
  cfg,
  lib,
  pkgs, 
  ...
}: let
  inherit (lib.attrsets) concatMapAttrs mapAttrs;

  mkExtensions = extensions: concatMapAttrs 
    (_: extension: {
      ${extension.addonID} = {
	install_url = extension.installUrl;
	installation_mode = extension.installMode;
	default_area = "menupanel";
      };
    }) extensions;

in {
  AppAutoUpdate = false;

  ## Security / Privacy
  OverrideFirstRunPage = "";
  DisableTelemetry = true;
  DisableFirefoxStudies = true;
  DisableFirefoxAccounts = true;
  DisablePocket = true;
  DisableSetDesktopBackground = true;
  PromptForDownloadLocation = true;

  # Tracking Protection
  EnableTrackingProtection = {
    Cryptomining = true;
    Fingerprinting = true;
    Locked = true;
    Value = true;
  };

  ExtensionSettings = (mkExtensions cfg.extensions) // {
    # Blocks about:debugging
    # https://bugzilla.mozilla.org/show_bug.cgi?id=1778559
    #"*".installation_mode = "blocked";
  };
  ExtensionUpdate = false;

  # Firefox Home
  FirefoxHome = {
    Search = true;
    Pocket = false;
    Snippets = false;
    TopSites = false;
    Highlights = false;
  };

  # How Schizofox should handle cookies
  Cookies = {
    Behavior = "accept";
    Locked = false;
  };

  # Attempt to support Smartcards (e.g. Nitrokeys) by using a proxy module.
  # This should provide an easier interface than `nixpkgs.config.firefox.smartcardSupport = true`
  SecurityDevices = {
    "PKCS#11 Proxy Module" = "${pkgs.p11-kit}/lib/p11-kit-proxy.so";
  };

  ## Shutdown sanitization behaviour
  DisableFormHistory = true;

  ## Irrelevant
  DontCheckDefaultBrowser = true;

  ## Misc
  NoDefaultBookmarks = true;
  OfferToSaveLogins = false;
  PasswordManagerEnabled = false;
  DisplayBookmarksToolbar = false;
  TranslateEnabled = true;
  ShowHomeButton = false;

  # User Messaging
  UserMessaging = {
    ExtensionRecommendations = false;
    SkipOnboarding = true;
    MoreFromMozilla = false;
  };
}
