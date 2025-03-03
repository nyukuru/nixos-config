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
    (lib.strings)
    concatStringsSep
    ;

  inherit
    (lib.attrsets)
    removeAttrs
    attrNames
    attrHead
    ;

  inherit
    (lib.types)
    listOf
    enum
    str
    ;

  inherit
    (lib.meta)
    getExe
    ;

  cfg = config.nyu.boot.greetd;
  wm = config.nyu.windowManager.default;
in {
  options.nyu.boot.greetd = {
    enable = mkEnableOption "greetd.";

    greeter = mkPackageOption pkgs.greetd "greetd" {
      default = "tuigreet";
    };

    command = mkOption {
      type = str;
      default =
        if wm == null
        then "${getExe config.users.defaultUserShell}"
        else "${getExe wm}";
      description = "Command executed by the greeter upon login / autologin.";
    };

    greeterArgs = mkOption {
      type = listOf str;
      default = [
        "--time"
        "--remember"
        "--asterisks-char"
        "\"-\""
      ];
      description = "Command line arguments applied to the greeter.";
    };

    autologin = {
      enable = mkEnableOption "Autologin.";
      user = mkOption {
        type = enum (attrNames config.users.users);
        default = attrHead (removeAttrs config.users.users ["root"]);
        description = "Determines which user is automatically logged in.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      vt = 1;

      settings = {
        # default greeter that requires login
        default_session = {
          user = "greeter";
          command = concatStringsSep " " ([
              (getExe cfg.greeter)
              "--cmd ${cfg.command}"
            ]
            ++ cfg.greeterArgs);
        };

        # autologin start wm
        initial_session = mkIf cfg.autologin.enable {
          inherit (cfg.autologin) user;
          inherit (cfg) command;
        };
      };
    };
  };
}
