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
    mkForce
    mkIf
    ;

  inherit
    (lib.strings)
    concatStringsSep
    concatMapStringsSep
    ;

  inherit
    (lib.attrsets)
    attrNames
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

  sessions = config.services.displayManager.sessionPackages;
  cfg = config.nyu.boot.greetd;
in {
  options.nyu.boot.greetd = {
    enable = mkEnableOption "greetd.";

    greeter = mkPackageOption pkgs "greetd" {
      default = "tuigreet";
    };

    greeterArgs = mkOption {
      type = listOf str;
      default = [
        "--time"
        "--remember"
        "--remember-user-session"
        "--sessions ${concatMapStringsSep ":" (x: x + "/share/wayland-sessions") sessions}"
      ];
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

  config = mkIf cfg.enable {
    services.displayManager.enable = mkForce false;
    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          command = concatStringsSep " " (
            [(getExe cfg.greeter)]
            ++ cfg.greeterArgs
          );
        };

        # autologin start wm
        initial_session = mkIf cfg.autologin.enable {
          inherit (cfg.autologin) user command;
        };
      };
    };
  };
}
