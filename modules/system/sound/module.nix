{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;

  cfg = config.modules.system.sound;
in {
  imports = [
    # Defines current sound server.
    ./servers.nix
    # Adds realtime audio option and functionality.
    ./realtime.nix
  ];

  options.modules.system.sound = {
    enable = mkEnableOption "Sound capabilities." // {default = true;};
  };
}
