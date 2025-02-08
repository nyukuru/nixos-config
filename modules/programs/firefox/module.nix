{ 
  config, 
  pkgs,
  inputs',
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.modules) mkIf mkForce;
  inherit (lib.strings) concatMapAttrsStringSep toJSON;
  inherit (lib.types) listOf str path;

  inherit (inputs'.textfox.packages) wrapTextfox;
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

    extraUserChrome = mkOption {
      type = str;
      default = "";
      description = "CSS to be appended into userChrome.css in the firefox profile.";
    };

    extraUserContent = mkOption {
      type = str;
      default = "";
      description = "CSS to be appended into userContent.css in the firefox profile.";
    };

    theme = {
      backgroundColor = mkOption {
	type = str;
	default = "#242323";
	description = "Color of background, most elements will inherit from this.";
      };

      foregroundColor = mkOption {
	type = str;
	default = "#ffffff";
	description = "Color of title elements and tab titles.";
      };

      inactiveBorderColor = mkOption {
	type = str;
	default = "#956f76";
	description = "Color of border when not hovering the element.";
      };

      activeBorderColor = mkOption {
	type = str;
	default = "#ff9cb7";
	description = "Color of border of the currently hovered element.";
      };

      iconsColor = mkOption {
	type = str;
	default = "#ffffff";
	description = "Color of icons.";
      };

      font = mkOption {
	type = str;
	default = "\"JetBrainsMono Nerd Font\"";
	description = "Font for default browser elements.";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.firefox.enable = mkForce false;

    environment.systemPackages = let
      policies = import ./policies.nix {inherit cfg lib pkgs;};
      prefs = ''
	Cu.import("resource:///modules/AboutNewTab.jsm");
	AboutNewTab.newTabURL = "${cfg.newtab}";

       // Auto focus new tab content
       Cu.import("resource:///modules/BrowserWindowTracker.jsm");

       Services.obs.addObserver((event) => {
	   window = BrowserWindowTracker.getTopWindow();
	   window.gBrowser.selectedBrowser.focus();
	   }, "browser-open-newtab-start");

       pref("shyfox.enable.ext.mono.toolbar.icons", true);
       pref("shyfox.enable.ext.mono.context.icons", true);
       pref("shyfox.enable.context.menu.icons", true);
     '' + (concatMapAttrsStringSep "\n" 
      (name: value: "pref(\"${name}\", ${toJSON value});") 
      (import ./preferences.nix {inherit cfg;}));

    userChrome = ''
      #sidebar-box {
	z-index: 1000;
	position: relative;
	min-width: 0px !important;
	max-width: none !important;
	width: 60px !important; 
	transition: width 0.2s ease, border-color 0.2s ease !important;
	margin-top: calc((var(--urlbar-toolbar-height) + 14px) * -1 ) !important;
	&:hover {width: 248px !important;}
	&::before {margin: -0.85rem 7px !important}
      }

      #nav-bar {
	margin-left: calc(60px + 24px);
	transition: margin-left 0.2s ease !important;
	&::before {padding 0 2px !important}
      }

      body:has(#sidebar-box:hover) #nav-bar {
	margin-left: calc(248px + 24px);
	transition: margin-left 0.2s ease !important;
      }

      #tabbrowser-tabbox::before {
	margin: -1.3rem 5px;
	padding: 0 2px;
      }

      ::-moz-selection { background-color: var(--tf-border) !important;}
    '';

    userContent = ''
      @-moz-document regexp("^moz-extension://.*?/sidebar/sidebar.html") {
	#root.root:not(:hover) .Tab .body {
	  .title {opacity: 0;}
	  .audio {opacity: 0 !important;}
	  .fav {
	    left: 50%;
	    transform: translateX(-100%) !important;
	    transition: all 0.2s ease 128ms;
	  }
	}

	.Tab .body {
	  .title {transition: opacity 0.2s ease !important;}
	  .audio {transition: opacity 0.2s ease !important;}
	  .fav {
	    left: 0;
	    transition: all 70ms ease;
	  }
	}
      }
    '';

    in [
      (pkgs.symlinkJoin {
        name = "textfox-wrapped";
	paths = [(wrapTextfox cfg.package {
	  inherit (cfg) extraPrefsFiles extraPoliciesFiles;

	  extraPrefs = prefs;
	  extraPolicies = policies;
	  extraUserChrome = userChrome + cfg.extraUserChrome;
	  extraUserContent = userContent + cfg.extraUserContent;

	  configCss = ''
	    :root {
	      --tf-display-sidebar-tools: "none";
	      --tf-font-family: ${cfg.theme.font};
	      --tf-border: ${cfg.theme.inactiveBorderColor};
	      --tf-accent: ${cfg.theme.activeBorderColor};
	      --tf-bg: ${cfg.theme.backgroundColor};

	      --lwt-text-color: ${cfg.theme.foregroundColor};
	      --toolbarbutton-icon-fill: ${cfg.theme.iconsColor};
	      --focus-outline-color: transparent !important;
	    }
	  '';
	})];
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
