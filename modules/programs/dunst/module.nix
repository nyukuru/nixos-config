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
    mkIf
    ;

  inherit
    (lib.types)
    bool
    ;

  toml = pkgs.formats.toml {};
  cfg = config.nyu.programs.dunst;
in {
  options.nyu.programs.dunst = {
    enable = mkEnableOption "Dunst notification daemon.";
    package =
      mkPackageOption pkgs "dunst" {}
      // {
        apply = p:
          p.override {
            withX11 = cfg.enableX11;
            withWayland = cfg.enableWayland;
          };
      };

    settings = mkOption {
      type = toml.type;
      default = {};
      description = "Dunst configuration, see dunst(5)";
    };

    enableX11 = mkOption {
      type = bool;
      default = true;
      description = "Enable X11 support.";
    };

    enableWayland = mkOption {
      type = bool;
      default = true;
      description = "Enable Wayland support.";
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [cfg.package];
      etc."xdg/dunst/dunstrc".source = toml.generate "dunstrc" cfg.settings;
    };

    services.dbus.packages = [cfg.package];
  };
}
