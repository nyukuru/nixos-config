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
    mkOption;

  inherit 
    (lib.modules)
    mkForce
    mkIf;

  inherit 
    (lib.types)
    listOf
    path
    str;
    
  cfg = config.modules.programs.firefox;
in {
  imports = [./extensions.nix];

  options.modules.programs.firefox = {
    enable = mkEnableOption "Firefox web browser.";
    package = mkPackageOption pkgs "firefox-esr-128-unwrapped" {};

    languagePacks = mkOption {
      type = listOf str;
      default = ["en-US"];
      description = "Language-packs to install.";
    };

    newtab = mkOption {
      type = str;
      default = "about:blank";
      description = "URL of the newtab page.";
    };

    extraPoliciesFiles = mkOption {
      type = listOf path;
      default = [];
      description = ''
        Group policies to install.
        See https://mozilla.github.io/policy-templates
        or about:policies.
      '';
    };

    extraPrefsFiles = mkOption {
      type = listOf path;
      default = [];
      description = ''
        Preferences to be injected in mozilla.cfg.
        Allows preferences that would otherwise be locked via policy settings.
      '';
    };

    userChrome = mkOption {
      type = path;
      default = "";
      description = "userChrome.css file for the firefox profile.";
    };

    userContent = mkOption {
      type = path;
      default = "";
      description = "userContent.css file for the firefox profile.";
    };
  };

  config = mkIf cfg.enable {
    programs.firefox.enable = mkForce false;

    environment.systemPackages = let
      extraPolicies = import ./policies.nix {inherit cfg lib pkgs;};
      extraPrefs = import ./preferences.nix {inherit cfg lib pkgs;};

    in [(
      pkgs.wrapFirefox cfg.package {
	inherit (cfg) 
	  extraPrefsFiles 
	  extraPoliciesFiles;

	inherit
	  extraPolicies
	  extraPrefs;
      }
    )];
  };
}
