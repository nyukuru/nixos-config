{
  config,
  pkgs,
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
    nullOr
    str
    ;

  inherit
    (lib.attrsets)
    filterAttrs
    attrNames
    ;

  inherit
    (lib.lists)
    optional
    length
    head
    elem
    ;

  enabledWms = attrNames (filterAttrs (_: v: v.enable) (removeAttrs cfg.wm ["default"]));
  cfg = config.modules.system.display;
in {
  imports = [
    ./wm
  ];

  options.modules.system.display = {
    wm.default = mkOption {
      type = nullOr str;
      default =
        if (enabledWms != [])
        then head enabledWms
        else null;
      apply = w:
        if (elem w enabledWms)
        then cfg.wm.${w}.package
        else throw "Window manager ${w} must be enabled to be set as the default.";
      description = ''
               The window manager to default to.
        Determines some behaviors such as what to boot into.
      '';
    };
  };

  config = mkIf config.hardware.graphics.enable {
    warnings = optional (length enabledWms > 1) ''
      You have more then one window manager enabled, this may break
      functionality if you have not ensured options handle this correctly.
    '';
  };
}
