{
  lib,
  ...
}: let

  inherit
    (lib.options)
    mkEnableOption
    ;

in {
  imports = [
    ./servers.nix
    ./realtime.nix
  ];

  options.modules.system.sound = {
    enable = mkEnableOption "Sound capabilities." // {default = true;};
  };
}
