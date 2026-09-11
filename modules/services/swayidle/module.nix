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

  inherit
    (lib.types)
    submodule
    listOf
    nullOr
    ints
    str
    bool
    ;

  inherit
    (lib.lists)
    optional
    optionals
    concatMap
    ;

  inherit
    (lib.strings)
    escapeShellArgs
    ;

  cfg = config.nyu.services.swayidle;

  timeoutModule = submodule {
    options = {
      timeout = mkOption {
        type = ints.positive;
        description = "Seconds of inactivity before `command` runs.";
      };

      command = mkOption {
        type = str;
        description = "Command to run once `timeout` seconds of inactivity pass.";
      };

      resumeCommand = mkOption {
        type = nullOr str;
        default = null;
        description = "Command to run once activity resumes after `command` has fired.";
      };
    };
  };

  timeoutArgs =
    concatMap (
      t:
        ["timeout" (toString t.timeout) t.command]
        ++ optionals (t.resumeCommand != null) ["resume" t.resumeCommand]
    )
    cfg.timeouts;

  eventArgs =
    optionals (cfg.beforeSleep != null) ["before-sleep" cfg.beforeSleep]
    ++ optionals (cfg.afterResume != null) ["after-resume" cfg.afterResume]
    ++ optionals (cfg.lock != null) ["lock" cfg.lock]
    ++ optionals (cfg.unlock != null) ["unlock" cfg.unlock]
    ++ optionals (cfg.idleHint != null) ["idlehint" (toString cfg.idleHint)];

  args = optional cfg.waitForCommand "-w" ++ timeoutArgs ++ eventArgs;
in {
  options.nyu.services.swayidle = {
    enable = mkEnableOption "swayidle idle management daemon.";
    package = mkPackageOption pkgs "swayidle" {};

    waitForCommand = mkOption {
      type = bool;
      default = true;
      description = ''
        Pass swayidle `-w`: wait for each command to finish before
        continuing, so e.g. a `beforeSleep` lock command finishes before the
        system sleeps.
      '';
    };

    timeouts = mkOption {
      type = listOf timeoutModule;
      default = [
        {
          timeout = 100;
          command = "brightnessctl -s set 10%";
          resumeCommand = "brightnessctl -r";
        }
        {
          timeout = 200;
          command = "swaylock";
        }
        {
          timeout = 220;
          command = "niri msg action power-off-monitors";
          resumeCommand = "niri msg action power-on-monitors";
        }
      ];
      description = "Idle timeout events, see the EVENTS section of swayidle(1).";
    };

    beforeSleep = mkOption {
      type = nullOr str;
      default = "swaylock";
      description = "Command to run before the system sleeps.";
    };

    afterResume = mkOption {
      type = nullOr str;
      default = "niri msg action power-on-monitors";
      description = "Command to run after the system resumes from sleep.";
    };

    lock = mkOption {
      type = nullOr str;
      default = "pidof swaylock || swaylock";
      description = "Command to run when logind signals the session should lock.";
    };

    unlock = mkOption {
      type = nullOr str;
      default = null;
      description = "Command to run when logind signals the session should unlock.";
    };

    idleHint = mkOption {
      type = nullOr ints.positive;
      default = null;
      description = "Seconds of inactivity before logind's IdleHint is set.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    systemd.user.services.swayidle = {
      description = "swayidle idle management daemon";

      after = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];

      path = ["/run/current-system/sw"];

      unitConfig = {
        StartLimitIntervalSec = 30;
        StartLimitBurst = 5;
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/swayidle ${escapeShellArgs args}";
        Restart = "on-failure";
        RestartSec = 3;
        Slice = "session.slice";
      };
    };
  };
}
