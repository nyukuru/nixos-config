{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) nullOr path;

  cfg = config.modules.style;
in {
  options.modules.style = {
    wallpaper = mkOption {
      type = nullOr path;
      default = null;
      description = "Wallpaper background image";
    };
  };
}
