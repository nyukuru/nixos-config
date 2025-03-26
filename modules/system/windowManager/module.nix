{
  config,
  lib,
  ...
}: let
  inherit
    (lib.options)
    mkOption
    ;

  inherit
    (lib.modules)
    mkIf
    ;

  inherit
    (lib.types)
    package
    listOf
    nullOr
    ;

  inherit
    (lib.lists)
    optional
    head
    ;

  cfg = config.nyu.windowManager;
in {
  options.nyu.windowManager = {
    default = mkOption {
      type = nullOr package;
      default =
        if (cfg.enabled != [])
        then head cfg.enabled
        else null;
      description = ''
        The window manager package to default to.
        Determines some behaviors such as what to boot into.
      '';
    };

    enabled = mkOption {
      type = listOf package;
      default = [];
      internal = true;
      visible = false;
    };
  };

  config = mkIf config.hardware.graphics.enable {
    warnings = optional (cfg.default == null) ''
      No window manager enabled, you will boot into a shell
      rather than a graphical enironment.
    '';
  };
}
