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
    mkDefault
    mkForce
    mkIf
    mkMerge
    ;

  inherit
    (lib.strings)
    concatStringsSep
    concatMapStringsSep
    getName
    ;

  inherit
    (lib.attrsets)
    attrNames
    ;

  inherit
    (lib.types)
    listOf
    enum
    nullOr
    package
    str
    ;

  inherit
    (lib.meta)
    getExe
    getExe'
    ;

  sessions = config.services.displayManager.sessionPackages;
  colors = config.style.colors;
  cfg = config.nyu.boot.greetd;

  hex = c: "#${c}";

  isNoctalia = cfg.greeter != null && getName cfg.greeter == "noctalia-greeter";
in {
  options.nyu.boot.greetd = {
    enable = mkEnableOption "greetd." // {default = true;};

    greeter = mkOption {
      type = nullOr package;
      default = pkgs.noctalia-greeter;
      description = "Greeter shown for interactive logins; null disables it (e.g. for an always-autologin session).";
    };

    greeterArgs = mkOption {
      type = listOf str;
      default = [];
      description = "Command line arguments applied to the greeter.";
    };

    autologin = {
      enable = mkEnableOption "Autologin.";

      user = mkOption {
        type = enum (attrNames config.users.users);
        description = "Determines which user is automatically logged in.";
      };

      command = mkOption {
        type = str;
        description = "Autologin command, usually a session start";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.displayManager.enable = mkForce false;
      services.greetd = {
        enable = true;

        settings = {
          default_session =
            if cfg.greeter == null
            then {inherit (cfg.autologin) user command;}
            else {
              # Greeters discover sessions through XDG_DATA_DIRS.
              command = concatStringsSep " " (
                [
                  (getExe' pkgs.coreutils "env")
                  "XDG_DATA_DIRS=${concatMapStringsSep ":" (x: x + "/share") sessions}"
                  (getExe cfg.greeter)
                ]
                ++ cfg.greeterArgs
              );
            };

          # autologin start wm
          initial_session = mkIf cfg.autologin.enable {
            inherit (cfg.autologin) user command;
          };
        };
      };
    }

    # State dir, AccountsService and polkit; the greetd command above wins
    # over the module's own default.
    (mkIf isNoctalia {
      services.displayManager.noctalia-greeter = {
        enable = true;
        package = cfg.greeter;

        settings.appearance = {
          scheme = "Synced";
          theme_mode = "dark";
          font_family = mkDefault config.style.font.name;

          palette = {
            primary = hex colors.baseB;
            on_primary = hex colors.background;
            secondary = hex colors.base4;
            on_secondary = hex colors.background;
            tertiary = hex colors.base2;
            on_tertiary = hex colors.background;
            error = hex colors.base1;
            on_error = hex colors.background;
            surface = hex colors.background;
            on_surface = hex colors.foreground;
            surface_variant = hex colors.base8;
            on_surface_variant = hex colors.base6;
            outline = hex colors.base8;
            shadow = hex colors.base0;
            hover = hex colors.base8;
            on_hover = hex colors.foreground;
          };

          wallpaper =
            if config.style.wallpaper != null
            then {
              path = "${config.style.wallpaper}";
              fill_mode = "crop";
            }
            else {fill_color = hex colors.base0;};
        };
      };
    })
  ]);
}
