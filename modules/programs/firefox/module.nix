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
    package
    listOf
    either
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

    profileDir = mkOption {
      type = path;
      default = "/var/lib/firefox/default/profile";
      description = "Static profile directory to avoid polluting home.";
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
      type = either str package;
      default = "";
      description = "CSS to be appended into userChrome.css in the firefox profile.";
    };

    userContent = mkOption {
      type = either str package;
      default = "";
      description = "CSS to be appended into userContent.css in the firefox profile.";
    };
  };

  config = mkIf cfg.enable {
    programs.firefox.enable = mkForce false;

    environment.systemPackages = let
      extraPolicies = import ./policies.nix {inherit cfg lib pkgs;};
      extraPrefs = import ./preferences.nix {inherit cfg lib pkgs;};

    in [
      (pkgs.symlinkJoin {
        name = "firefox";
        paths = [
          (pkgs.wrapFirefox cfg.package ({
            inherit (cfg) 
	      extraPrefsFiles 
	      extraPoliciesFiles;

	    inherit
	      extraPolicies
	      extraPrefs;
          }))
        ];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/firefox \
          --add-flags '--profile' \
          --add-flags '${cfg.profileDir}'
        '';
      })
    ];

    # Create ephemeral firefox profile
    systemd.tmpfiles.rules = ["d  ${cfg.profileDir} 0777 root root -   -"];
  };
}
