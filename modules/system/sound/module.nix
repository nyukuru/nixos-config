{lib, ...}: let
  inherit
    (lib.options)
    mkEnableOption
    mkOption
    ;

  inherit
    (lib.types)
    enum
    ;
in {
  imports = [
    ./servers

    ./realtime.nix
  ];

  options.nyu.sound = {
    enable = mkEnableOption "Sound capabilities." // {default = true;};

    server = mkOption {
      type = enum ["pulseaudio" "pipewire"];
      default = "pipewire";
      description = ''
        Determines your sound server. Pipewire is the newer and more sane option.
        Pulseaudio should only be chosen if forced by hardware compatability.
      '';
    };
  };
}
