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
    nullOr
    package
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
    enable = mkEnableOption "greetd." // {default = true;};

    greeter = mkOption {
      type = nullOr package;
      default = pkgs.tuigreet;
      description = "Greeter shown for interactive logins; null disables it (e.g. for an always-autologin session).";
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
        default_session =
          if cfg.greeter == null
          then {inherit (cfg.autologin) user command;}
          else {
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
