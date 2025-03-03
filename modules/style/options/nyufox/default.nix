{
  config,
  pkgs,
  lib,
  ...
}: let

  inherit
    (lib.options)
    mkEnableOption
    mkOption
    ;

  inherit
    (lib.modules)
    mkIf
    ;

  inherit
    (lib.types)
    str
    int
    ;

  mkColorOption = default: item:
    mkOption {
      inherit default;
      type = str;
      description = "Color of ${item}.";
    };

  cfg = config.style.nyufox;
in {
  options.style.nyufox = {
    enable = mkEnableOption "nyu's firefox css edits";

    color = {
      background = mkColorOption "#16130f" "browser container";
      border = mkColorOption "#342d24" "background of content windows";
    };

    border = {
      width = mkOption {
        type = int;
	default = 2;
	description = "Width of border around elements";
      };

      rounding = mkOption {
	type = int;
	default = 2;
      };
    };

    margin = mkOption {
      type = int;
      default = 8;
    };

    font = {
      family = mkOption {
        type = str;
	default = "\"JetBrainsMono Nerd Font\"";
	description = "Font for the default browser elements";
      };

      size = mkOption {
        type = int;
	default = 14;
	description = "Size of browser text elements by pixels";
      };
    };
  };


  config = mkIf cfg.enable {
    nyu.programs.firefox = {
      userChrome = pkgs.writeText "userChrome.css" (import ./userChrome.nix {inherit cfg;});
      userContent = pkgs.writeText "userContent.css" (import ./userContent.nix {inherit cfg;});

      extensions = {
        sidebery = {installMode = "force_installed";};
      };
    };
  };
}
