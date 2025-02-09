{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit 
    (lib.options)
    mkEnableOption
    mkOption;

  inherit
    (lib.modules)
    mkForce
    mkIf;

  inherit
    (lib.types)
    str;

  mkColorOption = default: item: mkOption {
    inherit default;
    type = str;
    description = "Color of ${item}.";
  };

  cfg = config.modules.style.textfox;
in {
  options.modules.style.textfox = {
    enable = mkEnableOption "textfox css edits";

    color = {
      background = mkColorOption "#242323" "background";
      foreground = mkColorOption "#ffffff" "foreground";
      inactiveBorder = mkColorOption "#956f76" "inactive border";
      activeBorder = mkColorOption "#ff9cb7" "active border";
      icons = mkColorOption "#ffffff" "icons";
    };

    font = mkOption {
      type = str;
      default = "\"JetBrainsMono Nerd Font\"";
      description = "Font for default browser elements.";
    };

    extraUserChrome = mkOption {
      type = str;
      default = "";
    };

    extraUserContent = mkOption {
      type = str;
      default = "";
    };
  };

  config = let 
    configCss = ''
      :root {
        --tf-display-sidebar-tools: "none";
	--tf-font-family: ${cfg.font};
	--tf-border: ${cfg.color.inactiveBorder};
	--tf-accent: ${cfg.color.activeBorder};
	--tf-bg: ${cfg.color.background};

	--lwt-text-color: ${cfg.color.foreground};
	--toolbarbutton-icon-fill: ${cfg.color.icons};
      }
    '';

    userChrome = pkgs.stdenvNoCC.mkDerivation {
      name = "textfox-userChrome.css";
      src = pkgs.fetchFromGitHub {
	owner = "adriankarlen"; 
	repo = "textfox";
	rev = "68ae7744357157e5c30e807291fe04c6b2e36291";
	hash = "sha256-2QrxNbXmjYP3COZIrCaRwPWqVYVq9ryj2+VXsHilQaQ=";
      };

      patches = [
	./patches/full-sidebar.patch
      ];

      inherit (cfg) extraUserChrome;
      inherit configCss;
      passAsFile = ["extraUserChrome" "configCss"];
      dontBuild = true;
      installPhase = ''
	cat "chrome/overwrites.css" >> "$out"
	cat "chrome/userChrome.css" >> "$out"
	cat "chrome/sidebar.css" >> "$out"
	cat "chrome/browser.css" >> "$out"
	cat "chrome/findbar.css" >> "$out"
	cat "chrome/navbar.css" >> "$out"
	cat "chrome/urlbar.css" >> "$out"
	cat "chrome/menus.css" >> "$out"
	cat "chrome/tabs.css" >> "$out"
	cat "chrome/defaults.css" >> "$out"

	cat "$configCssPath" >> "$out"
	cat "$extraUserChromePath" >> "$out"
      '';
    };

    userContent = pkgs.stdenvNoCC.mkDerivation {
      name = "textfox-userContent.css";
      src = pkgs.fetchFromGitHub {
	owner = "adriankarlen"; 
	repo = "textfox";
	rev = "68ae7744357157e5c30e807291fe04c6b2e36291";
	hash = "sha256-2QrxNbXmjYP3COZIrCaRwPWqVYVq9ryj2+VXsHilQaQ=";
      };

      patches = [
	./patches/collapsed-tabs.patch
      ];

      inherit (cfg) extraUserContent;
      inherit configCss;
      dontBuild = true;
      passAsFile = ["extraUserContent" "configCss"];
      installPhase = ''
	cat "chrome/content/sidebery.css" >> "$out"
	cat "chrome/content/newtab.css" >> "$out"
	cat "chrome/content/about.css" >> "$out"
	cat "chrome/defaults.css" >> "$out"

	cat "$configCssPath" >> "$out"
	cat "$extraUserContentPath" >> "$out"
      '';
    };

  in mkIf cfg.enable {
    modules.programs.firefox = {
      userChrome = mkForce userChrome;
      userContent = mkForce userContent;
    };
  };
}
