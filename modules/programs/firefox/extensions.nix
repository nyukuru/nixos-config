{
  config,
  lib,
  ...
}: let
  inherit
    (lib.options)
    mkOption
    ;

  inherit
    (lib.attrsets)
    nameValuePair
    listToAttrs
    attrNames
    ;

  inherit
    (lib.lists)
    elem
    map
    ;

  inherit
    (lib.types)
    submodule
    attrsOf
    listOf
    enum
    str
    ;

  inherit
    (lib.trivial)
    warnIfNot
    ;

  addonIDs = {
    ublock-origin = "uBlock0@raymondhill.net";
    skip-redirect = "skipredirect@sblask";
    privacy-badger17 = "jid1-MnnxcxisBPnSXQ@jetpack";
    clearurls = "{74145f27-f039-47ce-a470-a662b129930a}";
    sponsorblock = "sponsorBlocker@ajay.app";
    simple-translate = "simple-translate@sienori";
    languagetool = "languagetool-webextension@languagetool.org";
    betterttv = "firefox@betterttv.net";
    frankerfacez = "frankerfacez@frankerfacez.com";
    disable-twitch-extensions = "disable-twitch-extensions@rootonline.de";
    sidebery = "{3c078156-979c-498b-8990-85f7987dd929}";
    bento = "{cb7f7992-81db-492b-9354-99844440ff9b}";
  };

  langToExtension = lang:
    nameValuePair lang {
      addonID = "langpack-${lang}@firefox.mozilla.org";
      installUrl = "https://releases.mozilla.org/pub/firefox/releases/${cfg.package.version}/linux-x86_64/xpi/${lang}.xpi";
      installMode = "force_installed";
    };

  extensionSubmodule = submodule ({name, ...}: {
    options = {
      shortID = mkOption {
        visible = false;
        type = str;
        default = name;
        readOnly = true;
        apply = p:
          warnIfNot
          (elem p (attrNames addonIDs) || (elem p cfg.languagePacks))
          "Extension ${p} does not have a predefined addonID"
          p;
      };

      installMode = mkOption {
        type = enum ["force_installed" "normal_installed"];
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
        default = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
        description = "URL at which the addon xpi is hosted.";
      };

      addonID = mkOption {
        type = str;
        default = addonIDs.${name} or "";
        description = "Mozilla defined ID of the extension.";
      };
    };
  });

  cfg = config.nyu.programs.firefox;
in {
  options.nyu.programs.firefox = {
    languagePacks = mkOption {
      type = listOf str;
      default = ["en-US"];
      description = "Language-packs to install.";
    };

    extensions = mkOption {
      type = attrsOf extensionSubmodule;
      default = {};
      description = "Firefox extension settings by shortID";
    };
  };

  config = {
    nyu.programs.firefox.extensions = listToAttrs (map langToExtension cfg.languagePacks);
  };
}
