{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.modules) mkIf;
  inherit (config.style) colors font;

  opaque = c: "${c}ff";
  cfg = config.nyu.programs.fuzzel;
  format = pkgs.formats.ini {};
in {
  options.nyu.programs.fuzzel = {
    enable = mkEnableOption "fuzzel application launcher.";
    package = mkPackageOption pkgs "fuzzel" {};

    settings = mkOption {
      type = format.type;
      default = {};
      description = ''
        fuzzel configuration, see fuzzel.ini(5). Section names are the
        section headers from fuzzel.ini (`main`, `colors`, `border`, ...).
        Written to /etc/xdg/fuzzel/fuzzel.ini.
      '';
      example = {
        main = {
          font = "monospace:size=8";
          prompt = "> ";
          icons-enabled = true;
        };
        colors = {
          background = "1c1917ff";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [cfg.package];
      etc."xdg/fuzzel/fuzzel.ini".source = format.generate "fuzzel.ini" cfg.settings;
    };

    nyu.programs.fuzzel.settings = {
       main = {
        font = "${font.name}:pixelsize=14";
        prompt = ''""'';
        icons-enabled = false;
      };

      colors = {
        background = opaque colors.base0;
        text = "${colors.foreground}ee";
        input = "${colors.foreground}ee";
        placeholder = "${colors.base6}ee";

        match = opaque colors.baseA;

        selection = opaque colors.base8;
        selection-text = "${colors.foreground}ee";
        selection-match = opaque colors.baseA;

        border = opaque colors.base8;
      };

      border = {
        width = 4;
        radius = 4;
      };
    };
  };
}
