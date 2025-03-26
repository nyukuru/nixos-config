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
    (lib.types)
    nullOr
    path
    str
    ;

  cfg = config.nyu.programs.firefox;
in {
  imports = [
    ./preferences.nix
    ./extensions.nix
    ./policies.nix
  ];

  options.nyu.programs.firefox = {
    enable = mkEnableOption "Firefox web browser.";
    package =
      mkPackageOption pkgs "firefox-esr-128-unwrapped" {}
      // {
        apply = p:
          pkgs.wrapFirefox p {
            extraPrefs = cfg.preferences;
            extraPolicies = cfg.policies;
          };
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
  };
}
