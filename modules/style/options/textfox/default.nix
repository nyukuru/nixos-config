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

    chrome = pkgs.stdenvNoCC.mkDerivation {
      inherit 
        (cfg) 
        extraUserChrome
	extraUserContent;

      inherit 
        configCss;

      name = "textfox-chrome";

      src = pkgs.fetchFromGitHub {
	owner = "adriankarlen"; 
	repo = "textfox";
	rev = "68ae7744357157e5c30e807291fe04c6b2e36291";
	hash = "sha256-2QrxNbXmjYP3COZIrCaRwPWqVYVq9ryj2+VXsHilQaQ=";
      };

      patches = [
	./patches/full-sidebar.patch
	./patches/obscolete-userChrome.patch
	./patches/collapsed-tabs.patch
      ];

      passAsFile = [
        "extraUserChrome"
	"extraUserContent"
	"configCss"
      ];

      dontBuild = true;
      dontConfigure = true;

      installPhase = ''
        mkdir -p "$out"
	cp -r "chrome/icons" "$out/icons"

	cat "chrome/overwrites.css" >> "$out/userChrome.css"
	cat "chrome/sidebar.css" >> "$out/userChrome.css"
	cat "chrome/browser.css" >> "$out/userChrome.css"
	cat "chrome/findbar.css" >> "$out/userChrome.css"
	cat "chrome/navbar.css" >> "$out/userChrome.css"
	cat "chrome/urlbar.css" >> "$out/userChrome.css"
	sed "s|./icons|$out/icons|g" "chrome/icons.css" >> "$out/userChrome.css"
	cat "chrome/menus.css" >> "$out/userChrome.css"
	cat "chrome/tabs.css" >> "$out/userChrome.css"
	cat "chrome/defaults.css" >> "$out/userChrome.css"

	cat "$configCssPath" >> "$out/userChrome.css"
	cat "$extraUserChromePath" >> "$out/userChrome.css"

	cat "chrome/content/sidebery.css" >> "$out/userContent.css"
	cat "chrome/content/newtab.css" >> "$out/userContent.css"
	cat "chrome/content/about.css" >> "$out/userContent.css"
	cat "chrome/defaults.css" >> "$out/userContent.css"

	cat "$configCssPath" >> "$out/userContent.css"
	cat "$extraUserContentPath" >> "$out/userContent.css"
      '';
    };

  in mkIf cfg.enable {
    modules.programs.firefox = {
      userChrome = mkForce "${chrome}/userChrome.css";
      userContent = mkForce "${chrome}/userContent.css";
    };
  };
}
