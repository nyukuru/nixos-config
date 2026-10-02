{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) optionalAttrs;

  inherit (config.style) colors wallpaper font;
  cfg = config.nyu.programs.hyprlock;

  wrapConfig = package:
    pkgs.symlinkJoin {
      name = "${package.pname or package.name}-wrapped";
      paths = [package];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram "$out/bin/hyprlock" --add-flags "--config /etc/hyprlock/config"
      '';
    };

  format = pkgs.formats.hyprconf {importantPrefixes = ["$" "monitor" "size"];};
in {
  options.nyu.programs.hyprlock = {
    enable = mkEnableOption "hyprlock screen locker.";
    package =
      mkPackageOption pkgs "hyprlock" {}
      // {apply = wrapConfig;};

    settings = mkOption {
      type = format.type;
      default = {};
      description = ''
        hyprlock configuration, see hyprlock(5) and
        https://wiki.hypr.land/Hypr-Ecosystem/hyprlock/. Attribute names are
        hyprlock's block/field names; a repeated block (e.g. multiple
        `label`s) is a list of attrsets. Written to /etc/hyprlock/config.
      '';
      example = {
        general.hide_cursor = true;
        background = [{path = "screenshot";}];
        label = [
          {
            text = "$TIME";
            font_size = 90;
          }
        ];
      };
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [cfg.package];
      etc."hyprlock/config".source = format.generate "hyprlock-config" cfg.settings;
    };

    nyu.programs.hyprlock.settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        ({
            color = "rgb(${colors.base0})";
            blur_passes = 3;
            blur_size = 8;
          }
          // (
            if wallpaper != null
            then {path = "${wallpaper}";}
            else {}
          ))
      ];

      input-field = [
        {
          size = "180, 180";
          rounding = -1;
          outline_thickness = 7;

          inner_color = "rgb(${colors.base0})";
          outer_color = "rgb(${colors.base8})";

          check_color = "rgb(${colors.base5})";
          fail_color = "rgb(${colors.base1})";
          capslock_color = "rgb(${colors.baseB})";

          placeholder_text = "";
          check_text = "...";
          fail_text = "";

          hide_input = true;
          hide_input_base_color = "rgb(${colors.baseA})";

          fade_on_empty = false;

          font_color = "rgba(${colors.foreground}ee)";
          font_family = font.name;

          position = "0, -160";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          text = "$TIME";
          font_size = 90;
          font_family = font.name;
          color = "rgba(${colors.foreground}ee)";

          position = "0, 200";
          halign = "center";
          valign = "center";
        }
        {
          text = ''cmd[update:60000] date +"%A, %d %B %Y"'';
          font_size = 24;
          font_family = font.name;
          color = "rgba(${colors.foreground}ee)";

          position = "0, 110";
          halign = "center";
          valign = "center";
        }
      ];
    }
    // optionalAttrs config.services.fprintd.enable {
      auth = {
        "fingerprint:enabled" = true;
      };
    };

    security.pam.services.hyprlock.fprintAuth = false;
  };
}
