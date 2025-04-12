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


  mkColorOption = default: mkOption {
    inherit default;
    type = str;
  };

  inherit (config.style) colors;
  cfg = config.style.nyufox;
in {
  options.style.nyufox = {
    enable = mkEnableOption "nyu's firefox css edits";

    color = {
      background = mkColorOption "#${colors.base0}";
      border = mkColorOption "#${colors.base8}";
    };

    border = {
      width = mkOption {
        type = int;
        default = 2;
        description = "Width of border around elements";
      };

      rounding = mkOption {
        type = int;
        default = 5;
        description = "Radius of the border elements";
      };
    };

    margin = mkOption {
      type = int;
      default = 8;
    };

    font = {
      family = mkOption {
        type = str;
        default = "\"JetBrains Mono\"";
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
