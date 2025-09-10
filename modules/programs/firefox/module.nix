{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.options)
    mkPackageOption
    mkEnableOption
    mkOption
    ;

  inherit
    (lib.modules)
    mkForce
    mkIf
    ;

  inherit
    (lib.lists)
    foldl
    map
    ;

  inherit
    (lib.types)
    submodule
    listOf
    nullOr
    lines
    path
    enum
    str
    ;

  extensionSubmodule = submodule ({config, ...}: {
    options = {
      shortID = mkOption {
        visible = false;
        type = str;
      };

      installMode = mkOption {
        type = enum ["force_installed" "normal_installed"];
        default = "force_installed";
        description = ''
          Installation mode of the extension

          'force_installed' : Extension is automatically installed but
          enabled to be uninstalled by the user.

          'normal_installed' : Extensions is automatically installed but
          can be removed by the user.
        '';
      };

      installUrl = mkOption {
        type = str;
        default = "https://addons.mozilla.org/firefox/downloads/latest/${config.shortID}/latest.xpi";
        description = "URL at which the addon xpi is hosted.";
      };

      addonID = mkOption {
        type = str;
        description = "Mozilla defined ID of the extension.";
      };
    };
  });

  langToExtension = lang: {
    shortID = lang;
    addonID = "langpack-${lang}@firefox.mozilla.org";
    installUrl = "https://releases.mozilla.org/pub/firefox/releases/${cfg.package.version}/linux-x86_64/xpi/${lang}.xpi";
    installMode = "force_installed";
  };

  mkExtensions = foldl (acc: extension:
    acc
    // {
      ${extension.addonID} = {
        install_url = extension.installUrl;
        installation_mode = extension.installMode;
        default_area = "menupanel";
      };
    }) {"*".installation_mode = "blocked";};

  json = pkgs.formats.json {};
  cfg = config.nyu.programs.firefox;
in {
  imports = [
    ./preferences.nix
    ./policies.nix
  ];

  options.nyu.programs.firefox = {
    enable = mkEnableOption "Firefox web browser.";
    package =
      mkPackageOption pkgs "firefox-esr-140-unwrapped" {}
      // {
        apply = p:
          pkgs.wrapFirefox p {
            extraPrefs = cfg.preferences;
            extraPolicies = cfg.policies;
          };
      };

    policies = mkOption {
      type = json.type;
      default = {};
      description = "Mozilla policies.";
    };

    preferences = mkOption {
      type = lines;
      default = "";
      description = "";
    };

    languagePacks = mkOption {
      type = listOf str;
      default = ["en-US"];
      description = "Language-packs to install.";
    };

    extensions = mkOption {
      type = listOf extensionSubmodule;
      default = [];
      description = "Firefox extension settings by shortID and addonID";
    };

    newtab = mkOption {
      type = str;
      default = "";
      description = "URL of the newtab page.";
    };

    userChrome = mkOption {
      type = nullOr path;
      default = null;
      description = "userChrome.css file for the firefox profile.";
    };

    userContent = mkOption {
      type = nullOr path;
      default = null;
      description = "userContent.css file for the firefox profile.";
    };
  };

  config = mkIf cfg.enable {
    programs.firefox.enable = mkForce false;

    environment.systemPackages = [cfg.package];

    nyu.programs.firefox.extensions = map langToExtension cfg.languagePacks;
    nyu.programs.firefox.policies.ExtensionSettings = mkExtensions cfg.extensions;
  };
}
