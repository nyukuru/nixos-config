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
    mkPackageOption
    ;

  inherit
    (lib.modules)
    mkIf
    ;

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
  };
}
