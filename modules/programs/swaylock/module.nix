{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) filterAttrs;
  inherit (lib.generators) mkValueStringDefault;

  inherit (config.style) colors wallpaper font;
  cfg = config.nyu.programs.swaylock;

  wrapConfig = package:
    pkgs.symlinkJoin {
      name = "${package.pname or package.name}-wrapped";
      paths = [package];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram "$out/bin/swaylock" --add-flags "--config /etc/swaylock/config"
      '';
    };

  format = pkgs.formats.keyValue {
    mkKeyValue = key: value:
      if value == true
      then key
      else "${key}=${mkValueStringDefault {} value}";
  };
in {
  options.nyu.programs.swaylock = {
    enable = mkEnableOption "swaylock screen locker.";
    package =
      mkPackageOption pkgs "swaylock" {}
      // {apply = wrapConfig;};

    settings = mkOption {
      type = format.type;
      default = {};
      description = ''
        swaylock configuration, see swaylock(1). Attribute names are
        swaylock's long option names with the leading dashes dropped; set a
        flag-only option (e.g. `ignore-empty-password`) to `true` to enable
        it, or `false`/leave unset to omit it. Written to
        /etc/swaylock/config.
      '';
      example = {
        ignore-empty-password = true;
        show-failed-attempts = true;
        color = "1c1917ff";
        font-size = 24;
      };
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [cfg.package];
      etc."swaylock/config".source =
        format.generate "swaylock-config"
        (filterAttrs (_: value: value != false) cfg.settings);
    };

    nyu.programs.swaylock.settings = {
      daemonize = true;
      ignore-empty-password = true;
      show-failed-attempts = false;
      indicator-caps-lock = true;

      color = colors.base0;

      font = font.name;
      font-size = 24;

      indicator-radius = 90;
      indicator-thickness = 7;

      inside-color = colors.base0;
      inside-clear-color = colors.base0;
      inside-ver-color = colors.base0;
      inside-wrong-color = colors.base0;

      ring-color = colors.base8;
      ring-clear-color = colors.base8;
      ring-ver-color = colors.base8;
      ring-wrong-color = colors.base1;

      line-uses-ring = true;

      key-hl-color = colors.baseA;
      bs-hl-color = colors.base1;

      text-color = "${colors.foreground}ee";
      text-clear-color = "${colors.foreground}ee";
      text-ver-color = "${colors.foreground}ee";
      text-wrong-color = "${colors.foreground}ee";
    }
    // (
    if wallpaper != null
      then {
        image = "${wallpaper}";
        scaling = "fill";
      }
    else {}
    );

    security.pam.services.swaylock = {};
  };
}
